using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FavouriteController : BaseCRUDController<Model.Favourite, FavouriteSearchObject, FavouriteInsertRequest, FavouriteUpdateRequest>
    {
        public FavouriteController(IFavouriteService service) : base(service) { }
    }
}
