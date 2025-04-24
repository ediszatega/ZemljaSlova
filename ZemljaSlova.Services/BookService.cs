using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
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
                query = query.Include("Author");
            }
            
            return base.AddFilter(search, query);
        }

        public override Model.Book GetById(int id)
        {
            var entity = Context.Set<Database.Book>()
                .Include(x => x.Author)
                .FirstOrDefault(x => x.Id == id);

            if (entity == null)
            {
                return null;
            }

            return Mapper.Map<Model.Book>(entity);
        }
    }
}
