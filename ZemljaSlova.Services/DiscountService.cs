using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class DiscountService : BaseCRUDService<Model.Discount, DiscountSearchObject, Database.Discount, DiscountInsertRequest, DiscountUpdateRequest>, IDiscountService
    {
        public DiscountService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override void BeforeInsert(DiscountInsertRequest request, Database.Discount entity)
        {
            ValidateDiscountInsertRequest(request);
            
            entity.UsageCount = 0;
            entity.IsActive = true; // New discounts are active by default
        }

        public override void AfterInsert(DiscountInsertRequest request, Database.Discount entity)
        {
            // For book-specific discounts add associations to books
            if (request.Scope == Model.DiscountScope.Book && request.BookIds?.Any() == true)
            {
                var books = Context.Books.Where(b => request.BookIds.Contains(b.Id)).ToList();
                foreach (var book in books)
                {
                    book.DiscountId = entity.Id;
                }
                Context.SaveChanges(); // Save the book associations
            }
        }

        public override void BeforeUpdate(DiscountUpdateRequest request, Database.Discount entity)
        {
            ValidateDiscountUpdateRequest(request, entity);
            
            // Handle book associations for book-specific discounts
            if (request.Scope == Model.DiscountScope.Book)
            {
                // Get currently discounted books
                var currentBookIds = Context.Books
                    .Where(b => b.DiscountId == entity.Id)
                    .Select(b => b.Id)
                    .ToList();

                var newBookIds = request.BookIds ?? new List<int>();

                // Books to remove
                var booksToRemove = currentBookIds.Except(newBookIds).ToList();
                if (booksToRemove.Any())
                {
                    var booksToUpdate = Context.Books.Where(b => booksToRemove.Contains(b.Id)).ToList();
                    foreach (var book in booksToUpdate)
                    {
                        book.DiscountId = null;
                    }
                }

                // Books to add
                var booksToAdd = newBookIds.Except(currentBookIds).ToList();
                if (booksToAdd.Any())
                {
                    var booksToUpdate = Context.Books.Where(b => booksToAdd.Contains(b.Id)).ToList();
                    foreach (var book in booksToUpdate)
                    {
                        book.DiscountId = entity.Id;
                    }
                }
            }
            else if (entity.Scope == 1) // Book scope
            {
                // If changing from Book scope to Order scope, remove all book associations
                var booksToRemove = Context.Books.Where(b => b.DiscountId == entity.Id).ToList();
                foreach (var book in booksToRemove)
                {
                    book.DiscountId = null;
                }
            }
        }

        public override IQueryable<Database.Discount> AddFilter(DiscountSearchObject search, IQueryable<Database.Discount> query)
        {
            if (search.IsActive.HasValue)
            {
                if (search.IsActive.Value)
                {
                    // When filtering for active discounts, include date range and usage validation
                    var now = DateTime.Now;
                    query = query.Where(d => d.IsActive && 
                                           d.StartDate <= now && 
                                           d.EndDate >= now &&
                                           (!d.MaxUsage.HasValue || d.UsageCount < d.MaxUsage.Value));
                }
                else
                {
                    // When filtering for inactive discounts, include expired, disabled, or usage-limited discounts
                    var now = DateTime.Now;
                    query = query.Where(d => !d.IsActive || 
                                           d.StartDate > now || 
                                           d.EndDate < now ||
                                           (d.MaxUsage.HasValue && d.UsageCount >= d.MaxUsage.Value));
                }
            }

            if (search.StartDateFrom.HasValue)
                query = query.Where(d => d.StartDate >= search.StartDateFrom.Value);

            if (search.StartDateTo.HasValue)
                query = query.Where(d => d.StartDate <= search.StartDateTo.Value);

            if (search.EndDateFrom.HasValue)
                query = query.Where(d => d.EndDate >= search.EndDateFrom.Value);

            if (search.EndDateTo.HasValue)
                query = query.Where(d => d.EndDate <= search.EndDateTo.Value);

            if (search.Scope.HasValue)
                query = query.Where(d => d.Scope == (int)search.Scope.Value);

            if (search.MinPercentage.HasValue)
                query = query.Where(d => d.DiscountPercentage >= search.MinPercentage.Value);

            if (search.MaxPercentage.HasValue)
                query = query.Where(d => d.DiscountPercentage <= search.MaxPercentage.Value);

            if (!string.IsNullOrEmpty(search.Code))
                query = query.Where(d => d.Code != null && d.Code.Contains(search.Code));

            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(d => d.Code != null && d.Code.ToLower().Contains(search.Name.ToLower()));

            if (search.HasUsageLimit.HasValue)
            {
                if (search.HasUsageLimit.Value)
                    query = query.Where(d => d.MaxUsage.HasValue);
                else
                    query = query.Where(d => !d.MaxUsage.HasValue);
            }

            if (search.BookId.HasValue)
            {
                query = query.Where(d => d.Scope == 1 && // Book scope
                                       Context.Books.Any(b => b.Id == search.BookId.Value && b.DiscountId == d.Id));
            }

            return base.AddFilter(search, query);
        }

        public async Task<Model.Discount?> GetDiscountByCode(string code)
        {
            var discount = await Context.Discounts
                .FirstOrDefaultAsync(d => d.Code == code);
            
            return discount != null ? Mapper.Map<Model.Discount>(discount) : null;
        }

        public async Task<bool> CanUseDiscountCode(string code)
        {
            var discount = await GetDiscountByCode(code);
            return discount != null && IsDiscountValid(discount);
        }

        public async Task<int> GetDiscountUsageCount(int discountId)
        {
            var discount = await Context.Discounts.FindAsync(discountId);
            return discount?.UsageCount ?? 0;
        }

        // Main business logic method
        public async Task<decimal> CalculateOrderDiscount(List<Model.OrderItem> orderItems, string? discountCode = null)
        {
            var now = DateTime.Now;
            decimal itemLevelDiscount = 0;
            decimal orderLevelDiscount = 0;

            // Calculate book-specific discounts
            foreach (var item in orderItems.Where(i => i.Book?.DiscountId != null))
            {
                var bookDiscount = await Context.Discounts
                    .FirstOrDefaultAsync(d => d.Id == item.Book!.DiscountId && 
                                            d.IsActive && 
                                            d.StartDate <= now && 
                                            d.EndDate >= now &&
                                            (!d.MaxUsage.HasValue || d.UsageCount < d.MaxUsage.Value));

                if (bookDiscount != null && item.Book?.Price.HasValue == true)
                {
                    var itemTotal = item.Book!.Price!.Value * item.Quantity;
                    var discountAmount = itemTotal * (bookDiscount.DiscountPercentage / 100);
                    itemLevelDiscount += discountAmount;
                }
            }

            // Calculate order-level discount (only if discount code is provided)
            if (!string.IsNullOrEmpty(discountCode))
            {
                var codeDiscount = await Context.Discounts
                    .FirstOrDefaultAsync(d => d.Code == discountCode && 
                                            d.IsActive && 
                                            d.StartDate <= now && 
                                            d.EndDate >= now &&
                                            (!d.MaxUsage.HasValue || d.UsageCount < d.MaxUsage.Value));

                if (codeDiscount != null)
                {
                    var orderTotal = orderItems
                        .Where(i => i.Book != null && i.Book.Price.HasValue)
                        .Sum(i => i.Book!.Price!.Value * i.Quantity);
                    orderLevelDiscount = orderTotal * (codeDiscount.DiscountPercentage / 100);
                }
            }

            // Return the better discount - no combining 
            return Math.Max(itemLevelDiscount, orderLevelDiscount);
        }

        private bool IsDiscountValid(Model.Discount discount)
        {
            var now = DateTime.Now;
            return discount.IsActive && 
                   discount.StartDate <= now && 
                   discount.EndDate >= now &&
                   (!discount.MaxUsage.HasValue || discount.UsageCount < discount.MaxUsage.Value);
        }

        public async Task IncrementDiscountUsage(int discountId)
        {
            var discount = await Context.Discounts.FindAsync(discountId);
            if (discount != null)
            {
                discount.UsageCount++;
                await Context.SaveChangesAsync();
            }
        }

        public async Task<List<Model.Book>> GetBooksWithDiscount(int discountId)
        {
            var books = await Context.Books
                .Where(b => b.DiscountId == discountId)
                .ToListAsync();
            
            return Mapper.Map<List<Model.Book>>(books);
        }

        public async Task<int> RemoveExpiredDiscountsFromBooks()
        {
            var now = DateTime.Now;
            
            // Find all books that have expired discounts
            var booksWithExpiredDiscounts = await Context.Books
                .Where(b => b.DiscountId != null && 
                           Context.Discounts.Any(d => d.Id == b.DiscountId && 
                                                     d.EndDate < now))
                .ToListAsync();

            // Remove discount associations
            foreach (var book in booksWithExpiredDiscounts)
            {
                book.DiscountId = null;
            }

            if (booksWithExpiredDiscounts.Any())
            {
                await Context.SaveChangesAsync();
            }

            return booksWithExpiredDiscounts.Count;
        }

        public async Task<List<Model.Discount>> GetExpiredDiscounts()
        {
            var now = DateTime.Now;
            var expiredDiscounts = await Context.Discounts
                .Where(d => d.EndDate < now)
                .ToListAsync();
            
            return Mapper.Map<List<Model.Discount>>(expiredDiscounts);
        }

        public override void BeforeDelete(Database.Discount entity)
        {
            // Check if discount has been used in orders or order items
            var hasOrderUsage = Context.Orders.Any(o => o.DiscountId == entity.Id);
            var hasOrderItemUsage = Context.OrderItems.Any(oi => oi.DiscountId == entity.Id);
            
            if (hasOrderUsage || hasOrderItemUsage)
            {
                throw new InvalidOperationException("Cannot delete discount that has been used in orders. Consider deactivating it instead.");
            }
            
            // Remove discount reference from all books that have this discount
            var booksWithDiscount = Context.Books
                .Where(b => b.DiscountId == entity.Id)
                .ToList();
                
            foreach (var book in booksWithDiscount)
            {
                book.DiscountId = null;
            }
        }

        private void ValidateDiscountInsertRequest(DiscountInsertRequest request)
        {
            if (request.StartDate >= request.EndDate)
                throw new ArgumentException("Start date must be before end date");
            
            if (request.StartDate < DateTime.Today)
                throw new ArgumentException("Start date cannot be in the past");
            
            if (request.DiscountPercentage <= 0 || request.DiscountPercentage > 100)
                throw new ArgumentException("Discount percentage must be between 0.01% and 100%");

            if (request.Scope == Model.DiscountScope.Book && (request.BookIds == null || !request.BookIds.Any()))
                throw new ArgumentException("At least one book must be specified for book-specific discounts");

            // Validate unique code if provided
            if (!string.IsNullOrEmpty(request.Code))
            {
                var existingDiscount = Context.Discounts.FirstOrDefault(d => d.Code == request.Code);
                if (existingDiscount != null)
                    throw new ArgumentException("Discount code already exists");
            }
        }

        private void ValidateDiscountUpdateRequest(DiscountUpdateRequest request, Database.Discount entity)
        {
            // Validate date range if both dates are provided
            var startDate = request.StartDate ?? entity.StartDate;
            var endDate = request.EndDate ?? entity.EndDate;
            
            if (startDate >= endDate)
                throw new ArgumentException("Start date must be before end date");
            
            // Validate discount percentage if provided
            if (request.DiscountPercentage.HasValue)
            {
                if (request.DiscountPercentage <= 0 || request.DiscountPercentage > 100)
                    throw new ArgumentException("Discount percentage must be between 0.01% and 100%");
            }

            // Validate book requirements if scope is being changed to Book
            if (request.Scope.HasValue && request.Scope == Model.DiscountScope.Book && (request.BookIds == null || !request.BookIds.Any()))
                throw new ArgumentException("At least one book must be specified for book-specific discounts");

            // Validate unique code if provided and different from current
            if (!string.IsNullOrEmpty(request.Code) && request.Code != entity.Code)
            {
                var existingDiscount = Context.Discounts.FirstOrDefault(d => d.Code == request.Code);
                if (existingDiscount != null)
                    throw new ArgumentException("Discount code already exists");
            }
        }
    }
}
