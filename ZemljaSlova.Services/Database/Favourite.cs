﻿using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class Favourite
{
    public int Id { get; set; }

    public int MemberId { get; set; }

    public int BookId { get; set; }

    public virtual Book Book { get; set; } = null!;

    public virtual Member Member { get; set; } = null!;
}
