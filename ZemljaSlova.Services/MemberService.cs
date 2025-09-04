using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Services.Utils;
using Microsoft.AspNetCore.Http;

namespace ZemljaSlova.Services
{
    public class MemberService : BaseCRUDService<Model.Member, MemberSearchObject, Database.Member, MemberInsertRequest, MemberUpdateRequest>, IMemberService
    {
        private readonly _200036Context _context;
        private readonly IMapper _mapper;
        private readonly IUserService _userService;

        public MemberService(_200036Context context, IMapper mapper, IUserService userService) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
            _userService = userService;
        }

        public override IQueryable<Database.Member> AddFilter(MemberSearchObject search, IQueryable<Database.Member> query)
        {
            if (search.IsUserIncluded == true)
            {
                query = query.Include("User");
            }
            
            // Always include Memberships for active/inactive filtering
            query = query.Include("Memberships");

            // Filter by name (firstName or lastName)
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(m => m.User.FirstName.ToLower().Contains(search.Name.ToLower()) || m.User.LastName.ToLower().Contains(search.Name.ToLower()));
            }

            if (!string.IsNullOrEmpty(search.Gender))
            {
                query = query.Where(m => m.User.Gender == search.Gender);
            }

            if (search.BirthYearFrom.HasValue)
            {
                query = query.Where(m => m.DateOfBirth.Year >= search.BirthYearFrom.Value);
            }
            if (search.BirthYearTo.HasValue)
            {
                query = query.Where(m => m.DateOfBirth.Year <= search.BirthYearTo.Value);
            }

            if (search.JoinedYearFrom.HasValue)
            {
                query = query.Where(m => m.JoinedAt.Year >= search.JoinedYearFrom.Value);
            }
            if (search.JoinedYearTo.HasValue)
            {
                query = query.Where(m => m.JoinedAt.Year <= search.JoinedYearTo.Value);
            }

            // Filter by active/inactive members
            // By default, show only active members unless ShowInactiveMembers is explicitly set to true
            if (!search.ShowInactiveMembers.HasValue || !search.ShowInactiveMembers.Value)
            {
                var today = DateTime.Today;
                query = query.Where(m => m.Memberships.Any(ms => ms.EndDate >= today));
            }

            if (!string.IsNullOrEmpty(search.SortBy))
            {
                switch (search.SortBy.ToLower())
                {
                    case "name":
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(m => m.User.FirstName + " " + m.User.LastName)
                            : query.OrderBy(m => m.User.FirstName + " " + m.User.LastName);
                        break;
                    default:
                        query = query.OrderBy(m => m.User.FirstName + " " + m.User.LastName);
                        break;
                }
            }
            else
            {
                query = query.OrderBy(m => m.User.FirstName + " " + m.User.LastName);
            }

            return base.AddFilter(search, query);
        }

        public override Model.Member GetById(int id)
        {
            var entity = _context.Members
                .Include(m => m.User)
                .FirstOrDefault(m => m.Id == id);

            if (entity == null)
            {
                return null;
            }

            return _mapper.Map<Model.Member>(entity);
        }

        public async Task<Model.Member> CreateMember(MemberInsertRequest request)
        {
            Database.Member member;
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    var user = new UserInsertRequest
                    {
                        FirstName = request.FirstName,
                        LastName = request.LastName,
                        Email = request.Email,
                        Gender = request.Gender,
                    };

                    // Validate password requirements
                    if (!PasswordValidator.IsValidPassword(request.Password))
                    {
                        throw new Exception(PasswordValidator.GetPasswordRequirementsMessage());
                    }
                    
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword(request.Password);
                    user.Password = hashedPassword;
                    Model.User createdUser = _userService.Insert(user);
                    await _context.SaveChangesAsync();

                    member = new Database.Member
                    {
                        UserId = createdUser.Id,
                        DateOfBirth = request.DateOfBirth,
                        JoinedAt = request.JoinedAt
                    };

                    _context.Members.Add(member);
                    await _context.SaveChangesAsync();
                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }

            return _mapper.Map<Model.Member>(member);
        }

        public async Task<Model.Member> UpdateMember(int id, MemberUpdateRequest request)
        {
            Database.Member member;
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    // First, get the member with its User
                    member = await _context.Members
                        .Include(m => m.User)
                        .FirstOrDefaultAsync(m => m.Id == id);

                    if (member == null)
                    {
                        throw new Exception("Member not found");
                    }

                    var userUpdateRequest = new UserUpdateRequest
                    {
                        FirstName = request.FirstName,
                        LastName = request.LastName,
                        Gender = request.Gender,
                        Email = request.Email
                    };

                    _mapper.Map(userUpdateRequest, member.User);

                    member.DateOfBirth = request.DateOfBirth;
                    
                    await _context.SaveChangesAsync();
                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }

            return _mapper.Map<Model.Member>(member);
        }

        public List<Model.Favourite> GetMemberFavourites(int memberId)
        {
            var favourites = _context.Favourites
                .Include(f => f.Book)
                .Where(f => f.MemberId == memberId)
                .ToList();

            return _mapper.Map<List<Model.Favourite>>(favourites);
        }

        public Model.Member GetByUserId(int userId)
        {
            var entity = _context.Members
                .Include(m => m.User)
                .FirstOrDefault(m => m.UserId == userId);

            if (entity == null) return null;

            return _mapper.Map<Model.Member>(entity);
        }

        public Model.Member GetByEmail(string email)
        {
            var entity = _context.Members
                .Include(m => m.User)
                .FirstOrDefault(m => m.User.Email == email);

            if (entity == null) return null;

            return _mapper.Map<Model.Member>(entity);
        }
        
        public override void BeforeDelete(Database.Member entity)
        {
            // Check if member has orders
            var hasOrders = _context.Orders
                .Any(o => o.MemberId == entity.Id);
            
            if (hasOrders)
            {
                throw new UserException("Nije moguće izbrisati člana koji ima ranije transakcije.");
            }
        }
        
        public override async Task<Model.Member> Delete(int id)
        {
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    // Get the member with related data
                    var member = await _context.Members
                        .Include(m => m.User)
                        .Include(m => m.UserBookClubs)
                        .FirstOrDefaultAsync(m => m.Id == id);

                    if (member == null)
                    {
                        return null;
                    }

                    // Call BeforeDelete to check restrictions
                    BeforeDelete(member);

                    var memberModel = _mapper.Map<Model.Member>(member);
                    
                    if (member.UserBookClubs != null && member.UserBookClubs.Any())
                    {
                        _context.UserBookClubs.RemoveRange(member.UserBookClubs);
                    }
                    
                    // Remove the member and user
                    _context.Members.Remove(member);
                    _context.Users.Remove(member.User);
                    
                    await _context.SaveChangesAsync();                
                    transaction.Commit();
    
                    return memberModel;
                }
                catch (UserException)
                {
                    transaction.Rollback();
                    throw;
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    throw new Exception($"Failed to delete member: {ex.Message}", ex);
                }
            }
        }

        public async Task<Model.Member> CreateMemberFromForm(IFormCollection form)
        {
            Database.Member member;
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    // Extract form data
                    var firstName = form["firstName"].ToString();
                    var lastName = form["lastName"].ToString();
                    var email = form["email"].ToString();
                    var password = form["password"].ToString();
                    var gender = form["gender"].ToString();
                    var dateOfBirth = DateTime.Parse(form["dateOfBirth"].ToString());
                    var joinedAt = DateTime.Parse(form["joinedAt"].ToString());

                    // Validate password requirements
                    if (!PasswordValidator.IsValidPassword(password))
                    {
                        throw new Exception(PasswordValidator.GetPasswordRequirementsMessage());
                    }

                    // Handle image upload
                    byte[] imageBytes = null;
                    if (form.Files.Count > 0 && form.Files[0].Length > 0)
                    {
                        var imageFile = form.Files[0];
                        using (var memoryStream = new MemoryStream())
                        {
                            await imageFile.CopyToAsync(memoryStream);
                            imageBytes = memoryStream.ToArray();
                        }
                    }

                    var user = new UserInsertRequest
                    {
                        FirstName = firstName,
                        LastName = lastName,
                        Email = email,
                        Gender = string.IsNullOrEmpty(gender) ? null : gender,
                        Password = BCrypt.Net.BCrypt.HashPassword(password)
                    };

                    Model.User createdUser = _userService.Insert(user);
                    
                    // Update user with image if provided
                    if (imageBytes != null)
                    {
                        var userEntity = _context.Users.FirstOrDefault(u => u.Id == createdUser.Id);
                        if (userEntity != null)
                        {
                            userEntity.Image = imageBytes;
                        }
                    }
                    
                    await _context.SaveChangesAsync();

                    member = new Database.Member
                    {
                        UserId = createdUser.Id,
                        DateOfBirth = dateOfBirth,
                        JoinedAt = joinedAt
                    };

                    _context.Members.Add(member);
                    await _context.SaveChangesAsync();
                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }

            return _mapper.Map<Model.Member>(member);
        }

        public async Task<Model.Member> UpdateMemberFromForm(int id, IFormCollection form)
        {
            Database.Member member;
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    // First, get the member with its User
                    member = await _context.Members
                        .Include(m => m.User)
                        .FirstOrDefaultAsync(m => m.Id == id);

                    if (member == null)
                    {
                        throw new Exception("Member not found");
                    }

                    // Extract form data
                    var firstName = form["firstName"].ToString();
                    var lastName = form["lastName"].ToString();
                    var email = form["email"].ToString();
                    var gender = form["gender"].ToString();
                    var dateOfBirth = DateTime.Parse(form["dateOfBirth"].ToString());

                    // Handle image upload
                    if (form.Files.Count > 0 && form.Files[0].Length > 0)
                    {
                        var imageFile = form.Files[0];
                        using (var memoryStream = new MemoryStream())
                        {
                            await imageFile.CopyToAsync(memoryStream);
                            member.User.Image = memoryStream.ToArray();
                        }
                    }

                    // Update user data
                    member.User.FirstName = firstName;
                    member.User.LastName = lastName;
                    member.User.Email = email;
                    member.User.Gender = string.IsNullOrEmpty(gender) ? null : gender;

                    // Update member data
                    member.DateOfBirth = dateOfBirth;
                    
                    await _context.SaveChangesAsync();
                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }

            return _mapper.Map<Model.Member>(member);
        }

    }
}
