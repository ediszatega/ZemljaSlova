using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Helpers;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;
using ZemljaSlova.Model.Enums;

namespace ZemljaSlova.API.Controllers
{
    //[Authorize]
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<Model.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        private readonly IUserService _userService;

        public UserController(IUserService service) : base(service)
        {
            _userService = service;
        }

        [HttpPost("employee_login")]
        [AllowAnonymous]
        public AuthResponse EmployeeLogin([FromBody] LoginRequest request)
        {
            return _userService.AuthenticateUser(request.Email, request.Password, "employee");
        }

		[HttpPost("member_login")]
		[AllowAnonymous]
		public AuthResponse MemberLogin([FromBody] LoginRequest request)
		{
            return _userService.AuthenticateUser(request.Email, request.Password, "member");
        }
        
        [HttpPost("change_password")]
        public async Task<ActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            var result = await _userService.ChangePassword(request);
            
            if (result)
            {
                return Ok(new { message = "Password changed successfully." });
            }
            
            return BadRequest(new { message = "Failed to change password. Please verify your current password is correct." });
        }
        
        [HttpPost("admin_change_password")]
        [Authorize(Roles = UserRoles.Admin)]
        public async Task<ActionResult> AdminChangePassword([FromBody] AdminChangePasswordRequest request)
        {
            var result = await _userService.AdminChangePassword(request);
            
            if (result)
            {
                return Ok(new { message = "Password changed successfully by admin." });
            }
            
            return BadRequest(new { message = "Failed to change password. User not found." });
        }

        [HttpPost("refresh-token")]
        [Authorize]
        public ActionResult RefreshToken()
        {
            try
            {
                var email = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;
                if (string.IsNullOrEmpty(email))
                {
                    return BadRequest("Invalid token");
                }

                var newToken = _userService.RefreshToken(email);
                if (newToken != null)
                {
                    return Ok(new { token = newToken });
                }

                return BadRequest("Failed to refresh token");
            }
            catch (Exception ex)
            {
                return BadRequest($"Error refreshing token: {ex.Message}");
            }
        }
    }
}