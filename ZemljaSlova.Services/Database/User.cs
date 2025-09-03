using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class User
{
    public int Id { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string? Gender { get; set; }

    public string Email { get; set; } = null!;

    public string Password { get; set; } = null!;

    public byte[]? Image { get; set; }

    public virtual ICollection<BookTransaction> BookTransactions { get; set; } = new List<BookTransaction>();

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();

    public virtual ICollection<Member> Members { get; set; } = new List<Member>();

    public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();

    public virtual ICollection<TicketTypeTransaction> TicketTypeTransactions { get; set; } = new List<TicketTypeTransaction>();
}
