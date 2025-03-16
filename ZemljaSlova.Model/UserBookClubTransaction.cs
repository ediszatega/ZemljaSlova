using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class UserBookClubTransaction
    {
        public int Id { get; set; }

        public byte ActivityTypeId { get; set; }

        public int UserBookClubId { get; set; }

        public int Points { get; set; }

        public DateTime CreatedAt { get; set; }

        public int? OrderItemId { get; set; }

        public int? BookTransactionId { get; set; }

        public virtual BookTransaction? BookTransaction { get; set; }

        public virtual OrderItem? OrderItem { get; set; }

        public virtual UserBookClub UserBookClub { get; set; } = null!;
    }
}
