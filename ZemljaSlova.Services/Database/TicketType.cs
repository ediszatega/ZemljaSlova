using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class TicketType
{
    public int Id { get; set; }

    public int EventId { get; set; }

    public decimal Price { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public int? InitialQuantity { get; set; }

    public virtual Event Event { get; set; } = null!;

    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

    public virtual ICollection<TicketTypeTransaction> TicketTypeTransactions { get; set; } = new List<TicketTypeTransaction>();

    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();
}
