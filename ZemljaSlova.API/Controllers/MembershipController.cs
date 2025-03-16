using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MembershipController : BaseCRUDController<Model.Membership, MembershipSearchObject, MembershipInsertRequest, MembershipUpdateRequest>
    {
        public MembershipController(IMembershipService service) : base(service) { }
    }
}
