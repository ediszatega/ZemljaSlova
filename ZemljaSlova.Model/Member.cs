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

        public virtual ICollection<Recommendation> Recommendations { get; set; } = new List<Recommendation>();
        
        public virtual User User { get; set; } = null!;
    }
}
