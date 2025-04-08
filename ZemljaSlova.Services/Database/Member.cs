using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class Member
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public DateOnly DateOfBirth { get; set; }

    public DateOnly JoinedAt { get; set; }

    public virtual ICollection<BookReservation> BookReservations { get; set; } = new List<BookReservation>();

    public virtual ICollection<Favourite> Favourites { get; set; } = new List<Favourite>();

    public virtual ICollection<Membership> Memberships { get; set; } = new List<Membership>();

    public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

    public virtual User User { get; set; } = null!;

    public virtual ICollection<UserBookClub> UserBookClubs { get; set; } = new List<UserBookClub>();
}
