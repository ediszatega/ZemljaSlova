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
    public interface IMembershipService : ICRUDService<Membership, MembershipSearchObject, MembershipInsertRequest, MembershipUpdateRequest>
    {
        Membership CreateMembershipByMember(MembershipInsertRequest request);
        Membership GetActiveMembership(int memberId);
        List<Membership> GetMemberMemberships(int memberId);
        bool HasActiveMembership(int memberId);
    }
}
