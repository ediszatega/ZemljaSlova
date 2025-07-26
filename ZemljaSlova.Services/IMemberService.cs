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
    public interface IMemberService : ICRUDService<Member, MemberSearchObject, MemberInsertRequest, MemberUpdateRequest>
    {
        public Task<Model.Member> CreateMember(MemberInsertRequest request);
        public Task<Model.Member> UpdateMember(int id, MemberUpdateRequest request);
        public List<Model.Favourite> GetMemberFavourites(int memberId);
        public Model.Member GetByUserId(int userId);
    }
}
