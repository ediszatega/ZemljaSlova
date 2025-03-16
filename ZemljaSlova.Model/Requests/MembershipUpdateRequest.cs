using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class MembershipUpdateRequest
    {
        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }
    }
}
