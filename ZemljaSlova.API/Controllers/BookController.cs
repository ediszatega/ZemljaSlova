using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookController : BaseCRUDController<Model.Book, BookSearchObject, BookInsertRequest, BookUpdateRequest>
    {
        public BookController(IBookService service) : base(service) { }
    }
}
