using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class MemberSearchObject : BaseSearchObject
    {
        public bool IsUserIncluded { get; set; }
        public string? Name { get; set; }
        public string? SortBy { get; set; }
        public string? SortOrder { get; set; }
        
        // Filter
        public string? Gender { get; set; }
        public int? BirthYearFrom { get; set; }
        public int? BirthYearTo { get; set; }
        public int? JoinedYearFrom { get; set; }
        public int? JoinedYearTo { get; set; }
        public bool? ShowInactiveMembers { get; set; }
    }
}
