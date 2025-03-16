using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class UserBookClubTransactionInsertRequest
    {
        public byte ActivityTypeId { get; set; }

        public int UserBookClubId { get; set; }

        public int Points { get; set; }

        public DateTime CreatedAt { get; set; }

        public int? OrderItemId { get; set; }

        public int? BookTransactionId { get; set; }
    }
}
