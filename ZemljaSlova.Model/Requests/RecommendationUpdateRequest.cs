using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class RecommendationUpdateRequest
    {
        public int MemberId { get; set; }
        public int BookId { get; set; }
    }
}
