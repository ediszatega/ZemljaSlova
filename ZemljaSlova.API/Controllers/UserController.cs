using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Helpers;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

namespace ZemljaSlova.API.Controllers
{
    [Authorize]
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
    }
}