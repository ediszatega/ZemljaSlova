using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class User
    {
        public int Id { get; set; }

        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string? Gender { get; set; }

        public string Email { get; set; } = null!;

        public string PasswordHash { get; set; } = null!;

        public virtual Employee? Employee { get; set; }

        public virtual ICollection<Favourite> Favourites { get; set; } = new List<Favourite>();

        public virtual Member? Member { get; set; }

        public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();

        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

        public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();
    }
}
