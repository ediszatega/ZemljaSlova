using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class TicketTypeTransaction
{
    public int Id { get; set; }

    public byte ActivityTypeId { get; set; }

    public int TicketTypeId { get; set; }

    public int Quantity { get; set; }

    public DateTime CreatedAt { get; set; }

    public int? EmployeeId { get; set; }

    public int? MemberId { get; set; }

    public string? Data { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual Member? Member { get; set; }

    public virtual TicketType TicketType { get; set; } = null!;
}
