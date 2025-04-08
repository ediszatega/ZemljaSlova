using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class NotificationUpdateRequest
    {
        public string Title { get; set; } = null!;

        public string Content { get; set; } = null!;

        public int? OrderId { get; set; }

        public int? MembershipId { get; set; }

        public int? BookReservationId { get; set; }
    }
}
