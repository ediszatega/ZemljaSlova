using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class NotificationInsertRequest
    {
        public string Title { get; set; } = null!;

        public string Content { get; set; } = null!;

        //public DateTime RecievedAt { get; set; }

        //public bool IsRead { get; set; }

        //public int UserId { get; set; }

        //public int? OrderId { get; set; }

        //public int? MembershipId { get; set; }

        //public int? BookReservation { get; set; }
    }
}
