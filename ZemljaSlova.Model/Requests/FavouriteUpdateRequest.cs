using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class FavouriteUpdateRequest
    {
        public int UserId { get; set; }

        public int BookId { get; set; }

        public DateTime AddedAt { get; set; }
    }
}
