using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class UserBookClubService : BaseCRUDService<Model.UserBookClub, UserBookClubSearchObject, Database.UserBookClub, UserBookClubInsertRequest, UserBookClubUpdateRequest>, IUserBookClubService
    {
        public UserBookClubService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<Model.UserBookClub?> GetByMemberAndYearAsync(int memberId, int year)
        {
            var entity = await Context.UserBookClubs
                .FirstOrDefaultAsync(ubc => ubc.MemberId == memberId && ubc.Year == year);

            return entity != null ? Mapper.Map<Model.UserBookClub>(entity) : null;
        }

        public async Task<Model.UserBookClub?> GetCurrentYearByMemberAsync(int memberId)
        {
            var currentYear = DateTime.Now.Year;
            return await GetByMemberAndYearAsync(memberId, currentYear);
        }

        public async Task<List<Model.UserBookClub>> GetByMemberAsync(int memberId)
        {
            var entities = await Context.UserBookClubs
                .Where(ubc => ubc.MemberId == memberId)
                .OrderByDescending(ubc => ubc.Year)
                .ToListAsync();

            return Mapper.Map<List<Model.UserBookClub>>(entities);
        }
    }
}
