using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class BookSearchObject : BaseSearchObject
    {
        public bool IsAuthorIncluded { get; set; }
        public string? Title { get; set; }
    }
}
