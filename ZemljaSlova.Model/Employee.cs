﻿using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Employee
    {
        public int UserId { get; set; }

        public string AccessLevel { get; set; } = null!;

        public virtual ICollection<BookTransaction> BookTransactions { get; set; } = new List<BookTransaction>();

        public virtual ICollection<TicketTypeTransaction> TicketTypeTransactions { get; set; } = new List<TicketTypeTransaction>();

        public virtual User User { get; set; } = null!;
    }
}
