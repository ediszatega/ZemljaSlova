﻿using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class Notification
{
    public int Id { get; set; }

    public string Title { get; set; } = null!;

    public string Content { get; set; } = null!;

    public DateTime RecievedAt { get; set; }

    public bool IsRead { get; set; }

    public int UserId { get; set; }

    public int? OrderId { get; set; }

    public int? MembershipId { get; set; }

    public int? BookReservationId { get; set; }

    public virtual BookReservation? BookReservation { get; set; }

    public virtual Membership? Membership { get; set; }

    public virtual Order? Order { get; set; }

    public virtual User User { get; set; } = null!;
}
