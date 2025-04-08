using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class UserBookClub
    {
        public int Id { get; set; }

        public int Year { get; set; }

        public int MemberId { get; set; }

        public virtual Member Member { get; set; } = null!;

        public virtual ICollection<UserBookClubTransaction> UserBookClubTransactions { get; set; } = new List<UserBookClubTransaction>();
    }
}
