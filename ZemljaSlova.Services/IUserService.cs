﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;

namespace ZemljaSlova.Services
{
    public interface IUserService : ICRUDService<User, UserSearchObject, UserUpsertRequest, UserUpsertRequest>
    {
        public Task<AuthenticationResponse> AuthenticateUser(string email, string password);
    }
}
