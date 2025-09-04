using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;
using ZemljaSlova.Model.Enums;
using System.Security.Claims;

namespace ZemljaSlova.API.Controllers
{
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
        [AllowAnonymous]
        public async Task<Model.Member> CreateMember([FromBody] MemberInsertRequest request)
        {
            return await _memberService.CreateMember(request);
        }

        [HttpPut("UpdateMember/{id}")]
        public async Task<Model.Member> UpdateMember(int id, [FromBody] MemberUpdateRequest request)
        {
            return await _memberService.UpdateMember(id, request);
        }

        [HttpPost("CreateMember/with-image")]
        [Consumes("multipart/form-data")]
        [AllowAnonymous]
        public async Task<Model.Member> CreateMemberWithImage()
        {
            return await _memberService.CreateMemberFromForm(Request.Form);
        }

        [HttpPut("UpdateMember/{id}/with-image")]
        [Consumes("multipart/form-data")]
        public async Task<Model.Member> UpdateMemberWithImage(int id)
        {
            return await _memberService.UpdateMemberFromForm(id, Request.Form);
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

        [HttpGet("GetMemberByUserId/{userId}")]
        public ActionResult<Model.Member> GetMemberByUserId(int userId)
        {
            try
            {
                var member = _memberService.GetByUserId(userId);
                if (member == null)
                {
                    return NotFound("Member not found for the given user ID.");
                }
                return Ok(member);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving the member.");
            }
        }

        [HttpGet("current")]
        [Authorize]
        public ActionResult<Model.Member> GetCurrentMember()
        {
            try
            {
                // Get email from JWT token
                var emailClaim = User.FindFirst(ClaimTypes.Email)?.Value;
                if (string.IsNullOrEmpty(emailClaim))
                {
                    return Unauthorized("Invalid token");
                }

                var member = _memberService.GetByEmail(emailClaim);
                if (member == null)
                {
                    return NotFound("Member not found");
                }

                return Ok(member);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving current member.");
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = UserRoles.Admin)]
        public override async Task<Model.Member> Delete(int id)
        {
            return await _memberService.Delete(id);
        }
    }
}
