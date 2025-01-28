using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class Ticket
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int TicketTypeId { get; set; }

    public int OrderItemId { get; set; }

    public DateTime PurchasedAt { get; set; }

    public bool IsUsed { get; set; }

    public virtual OrderItem OrderItem { get; set; } = null!;

    public virtual TicketType TicketType { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
