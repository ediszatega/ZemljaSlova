using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserBookClubTransactionController : BaseCRUDController<Model.UserBookClubTransaction, UserBookClubTransactionSearchObject, UserBookClubTransactionInsertRequest, UserBookClubTransactionUpdateRequest>
    {
        public UserBookClubTransactionController(IUserBookClubTransactionService service) : base(service) { }
    }
}
