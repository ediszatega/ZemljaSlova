﻿using System;
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
using ZemljaSlova.Model.Helpers;
using ZemljaSlova.Services.Utils;
namespace ZemljaSlova.Services
{
    public class UserService : BaseCRUDService<Model.User, UserSearchObject, Database.User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private readonly IConfiguration _configuration;
        public UserService(_200036Context context, IMapper mapper, IConfiguration configuration) : base(context, mapper)
        {
            _configuration = configuration;
        }

        public async Task<AuthResponse> AuthenticateUser(string email, string password, string role)
        {
            var user = Context.Users.FirstOrDefault(u => u.Email == email);

            if (user == null)
            {
                return new AuthResponse { Result = AuthResult.UserNotFound };
            }

            if (!BCrypt.Net.BCrypt.Verify(password, user.Password))
            {
                return new AuthResponse { Result = AuthResult.InvalidPassword };
            }

            // For employee login, determine the actual role based on access level
            if (role == "employee")
            {
                var employee = Context.Employees.FirstOrDefault(e => e.UserId == user.Id);
                if (employee == null)
                {
                    return new AuthResponse { Result = AuthResult.UserNotFound };
                }

                // Use the actual access level from the database
                var actualRole = employee.AccessLevel;
                var token = CreateToken(user, actualRole);
                
                return new AuthResponse { Result = AuthResult.Success, UserId = user.Id, Token = token, Role = actualRole };
            }

            // For member login
            var memberToken = CreateToken(user, role);
            return new AuthResponse { Result = AuthResult.Success, UserId = user.Id, Token = memberToken, Role = "member" };
        }

        // JWT creation method
        private string CreateToken(User user, string role)
        {
            List<Claim> claims = new List<Claim>
            {
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, role)
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

        public bool IsUserEmployee(int userId)
        {
            var userExists = Context.Employees
                                  .Any(employee => employee.UserId == userId && employee.AccessLevel == "employee");

            return userExists;
        }

        public bool IsUserAdmin(int userId)
        {
            var userExists = Context.Employees
                                  .Any(employee => employee.UserId == userId && employee.AccessLevel == "admin");

            return userExists;
        }

        public bool IsUserMember(int userId)
        {
            var userExists = Context.Members
                                  .Any(member => member.UserId == userId);

            return userExists;
        }
        
        public async Task<bool> ChangePassword(ChangePasswordRequest request)
        {
            var user = await Context.Users.FindAsync(request.UserId);
            
            if (user == null)
            {
                return false;
            }
            
            // Verify current password
            if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.Password))
            {
                return false;
            }

            if (request.NewPassword != request.NewPasswordConfirmation)
            {
                throw new Exception("New password and confirmation password do not match");
            }
            
            // Validate new password requirements
            if (!PasswordValidator.IsValidPassword(request.NewPassword))
            {
                throw new Exception(PasswordValidator.GetPasswordRequirementsMessage());
            }
            
            // Hash and set new password
            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.Password = hashedPassword;
            
            await Context.SaveChangesAsync();
            return true;
        }
        
        public async Task<bool> AdminChangePassword(AdminChangePasswordRequest request)
        {
            var user = await Context.Users.FindAsync(request.UserId);
            
            if (user == null)
            {
                return false;
            }

            if (request.NewPassword != request.NewPasswordConfirmation)
            {
                throw new Exception("New password and confirmation password do not match");
            }
            
            if (!PasswordValidator.IsValidPassword(request.NewPassword))
            {
                throw new Exception(PasswordValidator.GetPasswordRequirementsMessage());
            }
            
            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.Password = hashedPassword;
            
            await Context.SaveChangesAsync();
            return true;
        }
        

    }
}
