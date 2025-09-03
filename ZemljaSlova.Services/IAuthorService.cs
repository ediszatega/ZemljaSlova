using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using Microsoft.AspNetCore.Http;

namespace ZemljaSlova.Services
{
    public interface IAuthorService : ICRUDService<Author, AuthorSearchObject, AuthorUpsertRequest, AuthorUpsertRequest>
    {
        Author InsertFromForm(IFormCollection form);
        Author UpdateFromForm(int id, IFormCollection form);
    }
}
