using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class UserBookClub
    {
        public int Id { get; set; }

        public int Year { get; set; }

        public int UserId { get; set; }

        public virtual ICollection<UserBookClubTransaction> UserBookClubTransactions { get; set; } = new List<UserBookClubTransaction>();

        public virtual Member YearNavigation { get; set; } = null!;
    }
}
