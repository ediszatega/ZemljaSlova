using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class BookTransaction
{
    public int Id { get; set; }

    public byte ActivityTypeId { get; set; }

    public int BookId { get; set; }

    public int Quantity { get; set; }

    public DateTime CreatedAt { get; set; }

    public int UserId { get; set; }

    public string? Data { get; set; }

    public virtual Book Book { get; set; } = null!;

    public virtual User User { get; set; } = null!;

    public virtual ICollection<UserBookClubTransaction> UserBookClubTransactions { get; set; } = new List<UserBookClubTransaction>();
}
