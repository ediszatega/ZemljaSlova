using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;
using ZemljaSlova.Model.Enums;

namespace ZemljaSlova.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class VoucherController : BaseController<Model.Voucher, VoucherSearchObject>
    {
        private readonly IVoucherService _voucherService;
        
        public VoucherController(IVoucherService service) : base(service)
        {
            _voucherService = service;
        }

        [HttpPost("CreateMemberVoucher")]
        [Authorize(Roles = UserRoles.Member)]
        public virtual Model.Voucher CreateMemberVoucher(VoucherMemberInsertRequest request)
        {
            return _voucherService.InsertMemberVoucher(request);
        }

        [HttpPost("CreateAdminVoucher")]
        [Authorize(Roles = UserRoles.Admin)]
        public virtual Model.Voucher CreateAdminVoucher(VoucherAdminInsertRequest request)
        {
            return _voucherService.InsertAdminVoucher(request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = UserRoles.Admin)]
        public virtual async Task<Model.Voucher> Delete(int id)
        {
            return await _voucherService.Delete(id);
        }

        [HttpGet("GetVoucherByCode/{code}")]
        public async Task<ActionResult<Model.Voucher>> GetVoucherByCode(string code)
        {
            try
            {
                var voucher = await _voucherService.GetVoucherByCode(code);
                if (voucher == null)
                {
                    return NotFound("Voucher not found");
                }
                return Ok(voucher);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving the voucher.");
            }
        }
    }
}
