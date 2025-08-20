using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model.Enums;

namespace ZemljaSlova.Services
{
    public class BookService : BaseCRUDService<Model.Book, BookSearchObject, Database.Book, BookInsertRequest, BookUpdateRequest>, IBookService
    {
        private readonly IBookTransactionService _transactionService;
        private readonly IBookClubPointsService _bookClubPointsService;

        public BookService(_200036Context context, IMapper mapper, IBookTransactionService transactionService, IBookClubPointsService bookClubPointsService) : base(context, mapper)
        {
            _transactionService = transactionService;
            _bookClubPointsService = bookClubPointsService;
        }

        public override IQueryable<Database.Book> AddFilter(BookSearchObject search, IQueryable<Database.Book> query)
        {
            if (search.IsAuthorIncluded == true)
            {
                query = query.Include(b => b.Authors);
            }

            query = query.Include(b => b.Discount);

            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(b => b.Title.ToLower().Contains(search.Title.ToLower()));
            }

            if (search.MinPrice.HasValue)
            {
                query = query.Where(b => b.Price >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(b => b.Price <= search.MaxPrice.Value);
            }

            if (search.AuthorId.HasValue)
            {
                query = query.Where(b => b.Authors.Any(a => a.Id == search.AuthorId.Value));
            }

            if (search.IsAvailable.HasValue)
            {
                if (search.IsAvailable.Value)
                {
                    // Available books: current quantity > 0
                    query = query.Where(b => 
                        Context.BookTransactions
                            .Where(t => t.BookId == b.Id)
                            .GroupBy(t => t.BookId)
                            .Select(g => g.Sum(t => 
                                t.ActivityTypeId == (byte)ActivityType.Stock ? t.Quantity :
                                (t.ActivityTypeId == (byte)ActivityType.Sold || 
                                 t.ActivityTypeId == (byte)ActivityType.Remove || 
                                 t.ActivityTypeId == (byte)ActivityType.Rent) ? -t.Quantity : 0
                            ))
                            .FirstOrDefault() > 0
                    );
                }
                else
                {
                    // Unavailable books: current quantity <= 0
                    query = query.Where(b => 
                        !Context.BookTransactions.Any(t => t.BookId == b.Id) ||
                        Context.BookTransactions
                            .Where(t => t.BookId == b.Id)
                            .GroupBy(t => t.BookId)
                            .Select(g => g.Sum(t => 
                                t.ActivityTypeId == (byte)ActivityType.Stock ? t.Quantity :
                                (t.ActivityTypeId == (byte)ActivityType.Sold || 
                                 t.ActivityTypeId == (byte)ActivityType.Remove || 
                                 t.ActivityTypeId == (byte)ActivityType.Rent) ? -t.Quantity : 0
                            ))
                            .FirstOrDefault() <= 0
                    );
                }
            }

            if (search.BookPurpose.HasValue)
            {
                query = query.Where(b => b.BookPurpose == (int)search.BookPurpose.Value);
            }

            if (!string.IsNullOrEmpty(search.SortBy))
            {
                switch (search.SortBy.ToLower())
                {
                    case "title":
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(b => b.Title)
                            : query.OrderBy(b => b.Title);
                        break;
                    case "price":
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(b => b.Price)
                            : query.OrderBy(b => b.Price);
                        break;
                    default:
                        query = query.OrderBy(b => b.Title);
                        break;
                }
            }
            else
            {
                query = query.OrderBy(b => b.Title);
            }

            return query;
        }

        public override PagedResult<Model.Book> GetPaged(BookSearchObject search)
        {
            // Proactively clean up expired discounts when loading books for display
            CleanupExpiredDiscountsFromBooks();
            
            var pagedResult = base.GetPaged(search);
            
            // Calculate stock quantities for all books in the result
            foreach (var book in pagedResult.ResultList)
            {
                var currentQuantity = GetCurrentQuantityAsync(book.Id).Result;
                book.QuantityInStock = currentQuantity;
                book.IsAvailable = currentQuantity > 0;
            }
            
            return pagedResult;
        }

        public override Model.Book GetById(int id)
        {
            // Clean up expired discounts when loading individual books
            CleanupExpiredDiscountsFromBooks();
            
            var entity = Context.Books
                .Include(b => b.Authors)
                .Include(b => b.Discount)
                .FirstOrDefault(x => x.Id == id);

            if (entity == null)
            {
                return null;
            }

            var result = Mapper.Map<Model.Book>(entity);
            
            if (entity.Authors != null)
            {
                result.Authors = Mapper.Map<List<Model.Author>>(entity.Authors);
            }

            // Map discount information
            if (entity.Discount != null)
            {
                result.Discount = Mapper.Map<Model.Discount>(entity.Discount);
            }

            // Calculate current stock quantity
            var currentQuantity = GetCurrentQuantityAsync(id).Result;
            result.QuantityInStock = currentQuantity;
            result.IsAvailable = currentQuantity > 0;

            return result;
        }
        
        public override Model.Book Insert(BookInsertRequest request)
        {
            var entity = Mapper.Map<Database.Book>(request);
            
            Context.Books.Add(entity);
            Context.SaveChanges();
            
            if (request.AuthorIds != null && request.AuthorIds.Any())
            {
                foreach (var authorId in request.AuthorIds)
                {
                    var author = Context.Authors.Find(authorId);
                    if (author != null)
                    {
                        Context.BookAuthors.Add(new Database.BookAuthor
                        {
                            BookId = entity.Id,
                            AuthorId = authorId
                        });
                    }
                }
                
                Context.SaveChanges();
            }
            
            return GetById(entity.Id);
        }
        
        public override Model.Book Update(int id, BookUpdateRequest request)
        {
            var entity = Context.Books
                .Include(b => b.Authors)
                .FirstOrDefault(b => b.Id == id);
                
            if (entity == null)
            {
                return null;
            }
            
            Mapper.Map(request, entity);
            
            var existingRelationships = Context.BookAuthors
                .Where(ba => ba.BookId == id)
                .ToList();
                
            var authorIdsToKeep = request.AuthorIds ?? new List<int>();
            var relationshipsToRemove = existingRelationships
                .Where(r => !authorIdsToKeep.Contains(r.AuthorId))
                .ToList();
                
            if (relationshipsToRemove.Any())
            {
                Context.BookAuthors.RemoveRange(relationshipsToRemove);
            }
            
            if (request.AuthorIds != null)
            {
                var existingAuthorIds = existingRelationships.Select(r => r.AuthorId).ToList();
                var authorIdsToAdd = request.AuthorIds.Where(id => !existingAuthorIds.Contains(id)).ToList();
                
                foreach (var authorId in authorIdsToAdd)
                {
                    var author = Context.Authors.Find(authorId);
                    if (author != null)
                    {
                        Context.BookAuthors.Add(new Database.BookAuthor
                        {
                            BookId = id,
                            AuthorId = authorId
                        });
                    }
                }
            }
            
            Context.SaveChanges();
            return GetById(id);
        }

        public void AddAuthorToBook(int bookId, int authorId)
        {
            var book = Context.Books.Find(bookId);
            var author = Context.Authors.Find(authorId);
            
            if (book == null || author == null)
            {
                throw new ArgumentException("Book or Author not found");
            }
            
            // Check if relationship already exists
            var exists = Context.BookAuthors
                .Any(ba => ba.BookId == bookId && ba.AuthorId == authorId);
                
            if (!exists)
            {
                Context.BookAuthors.Add(new Database.BookAuthor
                {
                    BookId = bookId,
                    AuthorId = authorId
                });
                
                Context.SaveChanges();
            }
        }
        
        public void RemoveAuthorFromBook(int bookId, int authorId)
        {
            var bookAuthor = Context.BookAuthors
                .FirstOrDefault(ba => ba.BookId == bookId && ba.AuthorId == authorId);
                
            if (bookAuthor != null)
            {
                Context.BookAuthors.Remove(bookAuthor);
                Context.SaveChanges();
            }
        }

        private void CleanupExpiredDiscountsFromBooks()
        {
            var now = DateTime.Now;
            
            // Find books with expired discounts and remove them
            var booksWithExpiredDiscounts = Context.Books
                .Where(b => b.DiscountId != null && 
                           Context.Discounts.Any(d => d.Id == b.DiscountId && d.EndDate < now))
                .ToList();

            foreach (var book in booksWithExpiredDiscounts)
            {
                book.DiscountId = null;
            }

            if (booksWithExpiredDiscounts.Any())
            {
                Context.SaveChanges();
            }
        }

        public override void BeforeDelete(Database.Book entity)
        {
            // Restrict deletion on these cases
            var hasOrderItems = Context.OrderItems.Any(oi => oi.BookId == entity.Id);
            if (hasOrderItems)
            {
                throw new InvalidOperationException("Cannot delete book that has been ordered. Books with order history must be preserved for record keeping.");
            }

            var hasReservations = Context.BookReservations.Any(br => br.BookId == entity.Id);
            if (hasReservations)
            {
                throw new InvalidOperationException("Cannot delete book that has active reservations. Please cancel all reservations first.");
            }

            var hasTransactions = Context.BookTransactions.Any(bt => bt.BookId == entity.Id);
            if (hasTransactions)
            {
                throw new InvalidOperationException("Cannot delete book that has transaction history. Books with transaction records must be preserved for auditing purposes.");
            }

            // Remove book-author relationships and favourites
            var bookAuthors = Context.BookAuthors
                .Where(ba => ba.BookId == entity.Id)
                .ToList();
            
            if (bookAuthors.Any())
            {
                Context.BookAuthors.RemoveRange(bookAuthors);
            }

            var favourites = Context.Favourites
                .Where(f => f.BookId == entity.Id)
                .ToList();
                
            if (favourites.Any())
            {
                Context.Favourites.RemoveRange(favourites);
            }
        }

        public async Task<int> GetCurrentQuantityAsync(int bookId)
        {
            var transactions = await Context.BookTransactions
                .Where(t => t.BookId == bookId)
                .ToListAsync();

            int currentQuantity = 0;

            foreach (var transaction in transactions)
            {
                if (transaction.ActivityTypeId == (byte)ActivityType.Stock)
                {
                    currentQuantity += transaction.Quantity;
                }
                else if (transaction.ActivityTypeId == (byte)ActivityType.Sold || 
                         transaction.ActivityTypeId == (byte)ActivityType.Remove || 
                         transaction.ActivityTypeId == (byte)ActivityType.Rent)
                {
                    currentQuantity -= transaction.Quantity;
                }
            }

            return currentQuantity;
        }

        public async Task<int> GetPhysicalStockAsync(int bookId)
        {
            // For rental books - only consider Stock and Remove transactions
            // Rented books are still physically present, just rented out
            var transactions = await Context.BookTransactions
                .Where(t => t.BookId == bookId)
                .ToListAsync();

            int physicalStock = 0;

            foreach (var transaction in transactions)
            {
                if (transaction.ActivityTypeId == (byte)ActivityType.Stock)
                {
                    physicalStock += transaction.Quantity;
                }
                else if (transaction.ActivityTypeId == (byte)ActivityType.Sold || 
                         transaction.ActivityTypeId == (byte)ActivityType.Remove)
                {
                    physicalStock -= transaction.Quantity;
                }
            }

            return physicalStock;
        }

        public async Task<int> GetCurrentlyRentedQuantityAsync(int bookId)
        {
            var transactions = await Context.BookTransactions
                .Where(t => t.BookId == bookId)
                .ToListAsync();

            // Get rental transactions
            var rentTransactions = transactions.Where(t => t.ActivityTypeId == (byte)ActivityType.Rent);
            
            // Get return transactions (Stock transactions with "Vraćeno:" in data)
            var returnTransactions = transactions.Where(t => 
                t.ActivityTypeId == (byte)ActivityType.Stock && 
                t.Data != null && 
                t.Data.Contains("Vraćeno:"));

            int totalRented = rentTransactions.Sum(t => t.Quantity);
            int totalReturned = returnTransactions.Sum(t => t.Quantity);

            return Math.Max(0, totalRented - totalReturned);
        }

        public async Task<bool> IsAvailableForPurchaseAsync(int bookId, int requestedQuantity)
        {
            if (requestedQuantity <= 0)
                return false;

            var currentQuantity = await GetCurrentQuantityAsync(bookId);
            return currentQuantity >= requestedQuantity;
        }

        public async Task<bool> IsAvailableForRentalAsync(int bookId, int requestedQuantity)
        {
            if (requestedQuantity <= 0)
                return false;

            // For rental books, check physical stock instead of current quantity
            var physicalStock = await GetPhysicalStockAsync(bookId);
            return physicalStock >= requestedQuantity;
        }

        public async Task<bool> AddStockAsync(int bookId, int quantity, int userId, string? data = null)
        {
            if (quantity <= 0)
            {
                return false;
            }

            var userExists = await Context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                return false;
            }

            try
            {
                await _transactionService.CreateStockTransactionAsync(bookId, quantity, userId, data);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> SellBooksAsync(int bookId, int quantity, int userId, string? data = null)
        {
            if (quantity <= 0)
            {
                return false;
            }

            var userExists = await Context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                return false;
            }

            // Check if there are enough books in stock
            var isAvailable = await IsAvailableForPurchaseAsync(bookId, quantity);
            if (!isAvailable)
            {
                return false;
            }

            try
            {
                await _transactionService.CreateSoldTransactionAsync(bookId, quantity, userId, data);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> RemoveBooksAsync(int bookId, int quantity, int userId, string? data = null)
        {
            if (quantity <= 0)
            {
                return false;
            }

            var userExists = await Context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                return false;
            }

            // Check if there are enough books in stock
            var isAvailable = await IsAvailableForPurchaseAsync(bookId, quantity);
            if (!isAvailable)
            {
                return false;
            }

            try
            {
                await _transactionService.CreateRemoveTransactionAsync(bookId, quantity, userId, data);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> RentBooksAsync(int bookId, int quantity, int userId, string? data = null)
        {
            if (quantity <= 0)
            {
                return false;
            }

            var userExists = await Context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                return false;
            }

            // Check if there are enough books in physical stock for rental
            var isAvailable = await IsAvailableForRentalAsync(bookId, quantity);
            if (!isAvailable)
            {
                return false;
            }

            try
            {
                var bookTransaction = await _transactionService.CreateRentTransactionAsync(bookId, quantity, userId, data);
                
                var member = await Context.Members.FirstOrDefaultAsync(m => m.UserId == userId);
                if (member != null)
                {
                    await _bookClubPointsService.AwardPointsAsync(
                        member.Id, 
                        ActivityType.BookRental, 
                        20 * quantity, 
                        bookTransactionId: bookTransaction.Id
                    );
                }
                
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> ReturnBooksAsync(int bookId, int quantity, int userId, string? data = null)
        {
            if (quantity <= 0)
            {
                return false;
            }

            var userExists = await Context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                return false;
            }

            try
            {
                await _transactionService.CreateStockTransactionAsync(bookId, quantity, userId, data);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
