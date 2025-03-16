using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class TicketInsertRequest
    {
        public int UserId { get; set; }

        public int TicketTypeId { get; set; }

        public int OrderItemId { get; set; }

        public DateTime PurchasedAt { get; set; }

        public bool IsUsed { get; set; }
    }
}
