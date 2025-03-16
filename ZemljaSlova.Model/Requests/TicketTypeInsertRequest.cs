using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class TicketTypeInsertRequest
    {
        public int EventId { get; set; }

        public decimal Price { get; set; }

        public string Name { get; set; } = null!;

        public string? Description { get; set; }
    }
}
