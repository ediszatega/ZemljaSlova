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
    public class FavouriteController : BaseCRUDController<Model.Favourite, FavouriteSearchObject, FavouriteInsertRequest, FavouriteUpdateRequest>
    {
        private readonly IFavouriteService _favouriteService;

        public FavouriteController(IFavouriteService service) : base(service) 
        { 
            _favouriteService = service;
        }

        [HttpDelete("unfavourite")]
        public IActionResult Unfavourite([FromQuery] int memberId, [FromQuery] int bookId)
        {
            var result = _favouriteService.Unfavourite(memberId, bookId);
            if (result)
            {
                return Ok(new { message = "Book removed from favourites" });
            }
            return NotFound(new { message = "Book not found in favourites" });
        }
    }
}
