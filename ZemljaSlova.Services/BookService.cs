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
    public class BookService : BaseCRUDService<Model.Book, BookSearchObject, Database.Book, BookInsertRequest, BookUpdateRequest>, IBookService
    {
        public BookService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
