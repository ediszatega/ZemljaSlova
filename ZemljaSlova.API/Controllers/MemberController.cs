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
        private readonly IMemberService _memberService;

        public MemberController(IMemberService service) : base(service) 
        { 
            _memberService = service;
        }

        [HttpPost("CreateMember")]
        public async Task<Model.Member> CreateMember([FromBody] MemberInsertRequest request)
        {
            return await _memberService.CreateMember(request);
        }

        [HttpPut("UpdateMember/{id}")]
        public async Task<Model.Member> UpdateMember(int id, [FromBody] MemberUpdateRequest request)
        {
            return await _memberService.UpdateMember(id, request);
        }

        [HttpGet("GetMemberFavourites/{memberId}")]
        public ActionResult<List<Model.Favourite>> GetMemberFavourites(int memberId)
        {
            try
            {
                var favourites = _memberService.GetMemberFavourites(memberId);
                return Ok(favourites);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving member favourites.");
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "admin")]
        public override async Task<Model.Member> Delete(int id)
        {
            return await _memberService.Delete(id);
        }
    }
}
