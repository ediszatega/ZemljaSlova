using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class RecommendationSearchObject : BaseSearchObject
    {
        public int? MemberId { get; set; }
        public int? BookId { get; set; }
    }
}
