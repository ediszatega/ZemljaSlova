using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

namespace ZemljaSlova.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class BookController : BaseCRUDController<Model.Book, BookSearchObject, BookInsertRequest, BookUpdateRequest>
    {
        private readonly new IBookService _service;

        public BookController(IBookService service) : base(service) 
        {
            _service = service;
        }

        [HttpPost]
        [Consumes("application/json")]
        public override Model.Book Insert(BookInsertRequest request)
        {
            try
            {
                var result = base.Insert(request);
                return result;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [HttpPost("with-image")]
        [Consumes("multipart/form-data")]
        public Model.Book InsertWithImage()
        {
            try
            {
                var result = _service.InsertFromForm(Request.Form);
                return result;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [HttpPut("{id}")]
        [Consumes("application/json")]
        public override Model.Book Update(int id, BookUpdateRequest request)
        {
            try
            {
                var result = base.Update(id, request);
                return result;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [HttpPut("{id}/with-image")]
        [Consumes("multipart/form-data")]
        public Model.Book UpdateWithImage(int id)
        {
            try
            {
                var result = _service.UpdateFromForm(id, Request.Form);
                return result;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [HttpGet("{id}/image")]
        public IActionResult GetBookImage(int id)
        {
            try
            {
                var book = _service.GetById(id);
                if (book?.Image == null || book.Image.Length == 0)
                {
                    return NotFound("Slika nije pronađena");
                }

                return File(book.Image, "image/jpeg");
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Greška prilikom dobavljanja slike");
            }
        }
    }
}
