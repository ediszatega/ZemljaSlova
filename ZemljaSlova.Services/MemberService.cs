using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using Microsoft.EntityFrameworkCore;

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

                    // Update the associated User first
                    var userUpdateRequest = new UserUpdateRequest
                    {
                        FirstName = request.FirstName,
                        LastName = request.LastName,
                        Gender = request.Gender,
                        Password = member.User.Password // Keep the existing password
                    };

                    _mapper.Map(userUpdateRequest, member.User);

                    // Update the Email separately since it's not in UserUpdateRequest
                    member.User.Email = request.Email;
                    
                    // Now update the Member entity
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
        
    }
}
