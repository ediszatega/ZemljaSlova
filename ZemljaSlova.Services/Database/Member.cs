using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class Member
{
    public int UserId { get; set; }

    public DateOnly DateOfBirth { get; set; }

    public DateOnly JoinedAt { get; set; }

    public virtual ICollection<BookTransaction> BookTransactions { get; set; } = new List<BookTransaction>();

    public virtual ICollection<Membership> Memberships { get; set; } = new List<Membership>();

    public virtual ICollection<TicketTypeTransaction> TicketTypeTransactions { get; set; } = new List<TicketTypeTransaction>();

    public virtual User User { get; set; } = null!;

    public virtual ICollection<UserBookClub> UserBookClubs { get; set; } = new List<UserBookClub>();
}
