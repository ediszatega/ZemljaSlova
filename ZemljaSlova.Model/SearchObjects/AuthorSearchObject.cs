using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class AuthorSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? SortBy { get; set; }
        public string? SortOrder { get; set; }
    }
}
