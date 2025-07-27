using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class AuthorService : BaseCRUDService<Model.Author, AuthorSearchObject, Database.Author, AuthorUpsertRequest, AuthorUpsertRequest>, IAuthorService
    {
        public AuthorService(_200036Context context, IMapper mapper) : base(context, mapper)  
        {
        }

        public override IQueryable<Database.Author> AddFilter(AuthorSearchObject search, IQueryable<Database.Author> query)
        {
            // Filter by name (firstName or lastName)
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(a => a.FirstName.ToLower().Contains(search.Name.ToLower()) || a.LastName.ToLower().Contains(search.Name.ToLower()));
            }

            if (search.BirthYearFrom.HasValue)
            {
                query = query.Where(a => a.DateOfBirth.HasValue && a.DateOfBirth.Value.Year >= search.BirthYearFrom.Value);
            }

            if (search.BirthYearTo.HasValue)
            {
                query = query.Where(a => a.DateOfBirth.HasValue && a.DateOfBirth.Value.Year <= search.BirthYearTo.Value);
            }

            if (!string.IsNullOrEmpty(search.SortBy))
            {
                switch (search.SortBy.ToLower())
                {
                    case "name":
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(a => a.FirstName + " " + a.LastName)
                            : query.OrderBy(a => a.FirstName + " " + a.LastName);
                        break;
                    default:
                        query = query.OrderBy(a => a.FirstName + " " + a.LastName);
                        break;
                }
            }
            else
            {
                query = query.OrderBy(a => a.FirstName + " " + a.LastName);
            }

            return base.AddFilter(search, query);
        }

        public override void BeforeDelete(Database.Author entity)
        {
            // Check if author has books associated
            var bookAuthors = Context.BookAuthors.Where(ba => ba.AuthorId == entity.Id).ToList();
            
            if (bookAuthors.Any())
            {
                var bookCount = bookAuthors.Count;
                throw new InvalidOperationException($"Cannot delete author who has {bookCount} book(s) associated. Please remove the author from all books first.");
            }
        }
    }
}
