using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class TicketTypeTransactionInsertRequest
    {
        public byte ActivityTypeId { get; set; }

        public int TicketTypeId { get; set; }

        public int Quantity { get; set; }

        public DateTime CreatedAt { get; set; }

        public int UserId { get; set; }

        public string? Data { get; set; }
    }
}
