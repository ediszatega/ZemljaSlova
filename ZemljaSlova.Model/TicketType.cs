using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Text;

namespace ZemljaSlova.Model
{
    public class TicketType
    {
        public int Id { get; set; }

        public int EventId { get; set; }

        public decimal Price { get; set; }

        public string Name { get; set; } = null!;

        public string? Description { get; set; }

        public int? InitialQuantity { get; set; }

        public int? CurrentQuantity { get; set; }
    }
}
