using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class Employee
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public string AccessLevel { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
