using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Configuration;
namespace ZemljaSlova.Services
{
    public class UserService : BaseCRUDService<Model.User, UserSearchObject, Database.User, UserUpsertRequest, UserUpsertRequest>, IUserService
    {
        private readonly IConfiguration _configuration;
        public UserService(_200036Context context, IMapper mapper, IConfiguration configuration) : base(context, mapper)
        {
            _configuration = configuration;
        }

        public async Task<AuthenticationResponse> AuthenticateUser(string email, string password)
        {
            var user = context.Users.FirstOrDefault(u => u.Email == email);

            if (user == null)
            {
                return new AuthenticationResponse { Result = Util.AuthenticationResult.UserNotFound };
            }

            if (!BCrypt.Net.BCrypt.Verify(password, user.Password))
            {
                return new AuthenticationResponse { Result = Util.AuthenticationResult.InvalidPassword };
            }

            var token = CreateToken(user);

            return new AuthenticationResponse { Result = Util.AuthenticationResult.Success, UserId = user.UserId, Token = token };
        }

        // JWT creation method
        private string CreateToken(User user)
        {
            List<Claim> claims = new List<Claim>
            {
                new Claim(ClaimTypes.Email, user.Email),
            };
            var key = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(_configuration.GetSection("AppSettings:Token").Value));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                claims: claims, 
                expires: DateTime.Now.AddDays(1),
                signingCredentials: creds
                );

            var jwt = new JwtSecurityTokenHandler().WriteToken(token);

            return jwt;
        }
    }
}
