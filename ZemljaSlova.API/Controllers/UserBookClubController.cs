using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserBookClubController : BaseCRUDController<Model.UserBookClub, UserBookClubSearchObject, UserBookClubInsertRequest, UserBookClubUpdateRequest>
    {
        public UserBookClubController(IUserBookClubService service) : base(service) { }
    }
}
