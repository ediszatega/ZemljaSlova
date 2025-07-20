using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Model.Helpers;

namespace ZemljaSlova.Services
{
    public interface IUserService : ICRUDService<User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public Task<AuthResponse> AuthenticateUser(string email, string password, string role);
        public bool IsUserEmployee(int userId);
        public bool IsUserAdmin(int userId);
        public bool IsUserMember(int userId);
        public Task<bool> ChangePassword(ChangePasswordRequest request);
        public Task<bool> AdminChangePassword(AdminChangePasswordRequest request);
    }
}
