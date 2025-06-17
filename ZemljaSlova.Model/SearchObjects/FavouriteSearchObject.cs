using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class FavouriteSearchObject : BaseSearchObject
    {
        public bool? IsBookIncluded { get; set; }
        public bool? IsMemberIncluded { get; set; }
        public int? MemberId { get; set; }
        public int? BookId { get; set; }
    }
}
