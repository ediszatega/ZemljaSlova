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
    public class MemberController : BaseCRUDController<Model.Member, MemberSearchObject, MemberInsertRequest, MemberUpdateRequest>
    {
        public MemberController(IMemberService service) : base(service) { }
    }
}
