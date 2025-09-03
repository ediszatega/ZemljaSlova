using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class Author
{
    public int Id { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public DateTime? DateOfBirth { get; set; }

    public string? Genre { get; set; }

    public string? Biography { get; set; }

    public byte[]? Image { get; set; }

    public virtual ICollection<Book> Books { get; set; } = new List<Book>();
}
