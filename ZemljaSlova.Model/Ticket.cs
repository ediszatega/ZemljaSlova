using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Ticket
    {
        public int Id { get; set; }

        public int MemberId { get; set; }

        public int TicketTypeId { get; set; }

        public int OrderItemId { get; set; }

        public DateTime PurchasedAt { get; set; }

        public bool IsUsed { get; set; }

        public string Code { get; set; } = string.Empty;

        public virtual Member Member { get; set; } = null!;

        public virtual OrderItem OrderItem { get; set; } = null!;

        public virtual TicketType TicketType { get; set; } = null!;
    }
}
