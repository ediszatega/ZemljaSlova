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
    }
}
