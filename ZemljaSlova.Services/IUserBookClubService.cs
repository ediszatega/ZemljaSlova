using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;

namespace ZemljaSlova.Services
{
    public interface IUserBookClubService : ICRUDService<UserBookClub, UserBookClubSearchObject, UserBookClubInsertRequest, UserBookClubUpdateRequest>
    {
        Task<UserBookClub?> GetByMemberAndYearAsync(int memberId, int year);
        Task<UserBookClub?> GetCurrentYearByMemberAsync(int memberId);
        Task<List<UserBookClub>> GetByMemberAsync(int memberId);
    }
}
