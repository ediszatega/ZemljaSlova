using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class BookTransaction
    {
        public int Id { get; set; }

        public byte ActivityTypeId { get; set; }

        public int BookId { get; set; }

        public int Qantity { get; set; }

        public DateTime CreatedAt { get; set; }

        public int? EmployeeId { get; set; }

        public int? MemberId { get; set; }

        public string? Data { get; set; }

        public virtual Book Book { get; set; } = null!;

        public virtual Employee? Employee { get; set; }

        public virtual Member? Member { get; set; }

        public virtual ICollection<UserBookClubTransaction> UserBookClubTransactions { get; set; } = new List<UserBookClubTransaction>();
    }
}
