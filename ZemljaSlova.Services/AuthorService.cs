using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using Microsoft.AspNetCore.Http;

namespace ZemljaSlova.Services
{
    public class AuthorService : BaseCRUDService<Model.Author, AuthorSearchObject, Database.Author, AuthorUpsertRequest, AuthorUpsertRequest>, IAuthorService
    {
        public AuthorService(_200036Context context, IMapper mapper) : base(context, mapper)  
        {
        }

        public override IQueryable<Database.Author> AddFilter(AuthorSearchObject search, IQueryable<Database.Author> query)
        {
            // Filter by name (firstName or lastName)
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(a => a.FirstName.ToLower().Contains(search.Name.ToLower()) || a.LastName.ToLower().Contains(search.Name.ToLower()));
            }

            if (search.BirthYearFrom.HasValue)
            {
                query = query.Where(a => a.DateOfBirth.HasValue && a.DateOfBirth.Value.Year >= search.BirthYearFrom.Value);
            }

            if (search.BirthYearTo.HasValue)
            {
                query = query.Where(a => a.DateOfBirth.HasValue && a.DateOfBirth.Value.Year <= search.BirthYearTo.Value);
            }

            if (!string.IsNullOrEmpty(search.SortBy))
            {
                switch (search.SortBy.ToLower())
                {
                    case "name":
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(a => a.FirstName + " " + a.LastName)
                            : query.OrderBy(a => a.FirstName + " " + a.LastName);
                        break;
                    default:
                        query = query.OrderBy(a => a.FirstName + " " + a.LastName);
                        break;
                }
            }
            else
            {
                query = query.OrderBy(a => a.FirstName + " " + a.LastName);
            }

            return base.AddFilter(search, query);
        }

        public override void BeforeDelete(Database.Author entity)
        {
            // Check if author has books associated
            var bookAuthors = Context.BookAuthors.Where(ba => ba.AuthorId == entity.Id).ToList();
            
            if (bookAuthors.Any())
            {
                var bookCount = bookAuthors.Count;
                throw new UserException($"Nije moguće izbrisati autora koji ima knjige povezane sa njim.");
            }
        }

        public Model.Author InsertFromForm(IFormCollection form)
        {
            try
            {
                var request = new AuthorUpsertRequest
                {
                    FirstName = form["firstName"].FirstOrDefault() ?? "",
                    LastName = form["lastName"].FirstOrDefault() ?? "",
                    Genre = form["genre"].FirstOrDefault(),
                    Biography = form["biography"].FirstOrDefault()
                };

                // Handle date of birth
                var dateOfBirthString = form["dateOfBirth"].FirstOrDefault();
                if (!string.IsNullOrEmpty(dateOfBirthString) && DateTime.TryParse(dateOfBirthString, out var dateOfBirth))
                {
                    request.DateOfBirth = dateOfBirth;
                }

                // Handle image file
                var imageFile = form.Files["image"];
                if (imageFile != null && imageFile.Length > 0)
                {
                    using var memoryStream = new MemoryStream();
                    imageFile.CopyTo(memoryStream);
                    request.Image = memoryStream.ToArray();
                }

                var result = Insert(request);
                
                return result;
            }
            catch (UserException)
            {
                throw new UserException("Greška prilikom dodavanja autora");
            }
        }

        public Model.Author UpdateFromForm(int id, IFormCollection form)
        {
            try
            {
                var request = new AuthorUpsertRequest
                {
                    FirstName = form["firstName"].FirstOrDefault() ?? "",
                    LastName = form["lastName"].FirstOrDefault() ?? "",
                    Genre = form["genre"].FirstOrDefault(),
                    Biography = form["biography"].FirstOrDefault()
                };

                // Handle date of birth
                var dateOfBirthString = form["dateOfBirth"].FirstOrDefault();
                if (!string.IsNullOrEmpty(dateOfBirthString) && DateTime.TryParse(dateOfBirthString, out var dateOfBirth))
                {
                    request.DateOfBirth = dateOfBirth;
                }

                // Handle image file
                var imageFile = form.Files["image"];
                if (imageFile != null && imageFile.Length > 0)
                {
                    using var memoryStream = new MemoryStream();
                    imageFile.CopyTo(memoryStream);
                    request.Image = memoryStream.ToArray();
                }

                return Update(id, request);
            }
            catch (UserException)
            {
                throw new UserException("Greška prilikom ažuriranja autora");
            }
        }
    }
}
