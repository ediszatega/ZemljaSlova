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

namespace ZemljaSlova.Services
{
    public class BookService : BaseCRUDService<Model.Book, BookSearchObject, Database.Book, BookInsertRequest, BookUpdateRequest>, IBookService
    {
        public BookService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
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

            return base.AddFilter(search, query);
        }

        public override PagedResult<Model.Book> GetPaged(BookSearchObject search)
        {
            // Proactively clean up expired discounts when loading books for display
            CleanupExpiredDiscountsFromBooks();
            
            return base.GetPaged(search);
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
    }
}
