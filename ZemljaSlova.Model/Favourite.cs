﻿using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Favourite
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public int BookId { get; set; }

        public DateTime AddedAt { get; set; }

        public virtual Book Book { get; set; } = null!;

        public virtual User User { get; set; } = null!;
    }
}
