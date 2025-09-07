using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

namespace ZemljaSlova.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class AuthorController : BaseCRUDController<Model.Author, AuthorSearchObject, AuthorUpsertRequest, AuthorUpsertRequest>
    {
        private readonly new IAuthorService _service;

        public AuthorController(IAuthorService service) : base(service) 
        {
            _service = service;
        }

        [HttpPost("with-image")]
        [Consumes("multipart/form-data")]
        public Model.Author InsertWithImage()
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

        [HttpPut("{id}/with-image")]
        [Consumes("multipart/form-data")]
        public Model.Author UpdateWithImage(int id)
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
        public IActionResult GetAuthorImage(int id)
        {
            try
            {
                var author = _service.GetById(id);
                if (author?.Image == null || author.Image.Length == 0)
                {
                    return NotFound("Slika nije pronađena");
                }

                return File(author.Image, "image/jpeg");
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Greška prilikom dobavljanja slike");
            }
        }
    }
}
