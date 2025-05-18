using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Helpers;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

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
        public async Task<AuthResponse> EmployeeLogin([FromBody] LoginRequest request)
        {
            return await _userService.AuthenticateUser(request.Email, request.Password, "employee");
        }

		[HttpPost("member_login")]
		[AllowAnonymous]
		public async Task<AuthResponse> MemberLogin([FromBody] LoginRequest request)
		{
            return await _userService.AuthenticateUser(request.Email, request.Password, "member");
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
    }
}