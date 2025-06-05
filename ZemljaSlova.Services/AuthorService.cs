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
