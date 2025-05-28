using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class MembershipSearchObject : BaseSearchObject
    {
        public bool? IsActive { get; set; }
        public bool? IsExpired { get; set; }
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
        public DateTime? EndDateFrom { get; set; }
        public DateTime? EndDateTo { get; set; }
        public bool? IncludeMember { get; set; }
    }
}
