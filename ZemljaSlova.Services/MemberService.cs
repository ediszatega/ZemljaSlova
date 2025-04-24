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
    }
}
