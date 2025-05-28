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
    public class MembershipController : BaseCRUDController<Model.Membership, MembershipSearchObject, MembershipInsertRequest, MembershipUpdateRequest>
    {
        private readonly IMembershipService _membershipService;

        public MembershipController(IMembershipService service) : base(service) 
        { 
            _membershipService = service;
        }

        [HttpPost("create_membership_by_member")]
        //[Authorize(Roles = "Member")]
        public ActionResult<Model.Membership> CreateMembershipByMember([FromBody] MembershipInsertRequest request)
        {
            try
            {
                var membership = _membershipService.CreateMembershipByMember(request);
                return Ok(membership);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while creating membership.");
            }
        }

        [HttpPost("create_membership_by_admin")]
        //[Authorize(Roles = "Admin,Employee")]
        public ActionResult<Model.Membership> CreateMembershipByAdmin([FromBody] MembershipInsertRequest request)
        {
            try
            {
                var membership = _membershipService.Insert(request);
                return Ok(membership);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while creating membership.");
            }
        }

        [HttpGet("get_active_membership/{memberId}")]
        public ActionResult<Model.Membership> GetActiveMembership(int memberId)
        {
            try
            {
                var membership = _membershipService.GetActiveMembership(memberId);
                if (membership == null)
                {
                    return NotFound("No active membership found for this member.");
                }
                return Ok(membership);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving active membership.");
            }
        }

        [HttpGet("get_member_memberships/{memberId}")]
        public ActionResult<List<Model.Membership>> GetMemberMemberships(int memberId)
        {
            try
            {
                var memberships = _membershipService.GetMemberMemberships(memberId);
                return Ok(memberships);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving member memberships.");
            }
        }
    }
}
