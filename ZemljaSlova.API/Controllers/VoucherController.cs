using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

namespace ZemljaSlova.API.Controllers
{
    //[Authorize]
    [ApiController]
    [Route("[controller]")]
    public class VoucherController : BaseCRUDController<Model.Voucher, VoucherSearchObject, VoucherUpsertRequest, VoucherUpsertRequest>
    {
        public VoucherController(IVoucherService service) : base(service) { }
    }
}
