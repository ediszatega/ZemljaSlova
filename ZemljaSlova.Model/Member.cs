using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Member
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public DateTime DateOfBirth { get; set; }

        public DateTime JoinedAt { get; set; }

        public virtual ICollection<BookReservation> BookReservations { get; set; } = new List<BookReservation>();

        public virtual ICollection<Favourite> Favourites { get; set; } = new List<Favourite>();

        public virtual ICollection<Membership> Memberships { get; set; } = new List<Membership>();

        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

        public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

        public virtual User User { get; set; } = null!;

        public virtual ICollection<UserBookClub> UserBookClubs { get; set; } = new List<UserBookClub>();

        public virtual ICollection<Voucher> Vouchers { get; set; } = new List<Voucher>();
    }
}
