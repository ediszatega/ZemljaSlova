using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Member
    {
        public int UserId { get; set; }

        public DateTime DateOfBirth { get; set; }

        public DateTime JoinedAt { get; set; }

        public virtual ICollection<BookTransaction> BookTransactions { get; set; } = new List<BookTransaction>();

        public virtual ICollection<Membership> Memberships { get; set; } = new List<Membership>();

        public virtual ICollection<TicketTypeTransaction> TicketTypeTransactions { get; set; } = new List<TicketTypeTransaction>();

        public virtual User User { get; set; } = null!;

        public virtual ICollection<UserBookClub> UserBookClubs { get; set; } = new List<UserBookClub>();
    }
}
