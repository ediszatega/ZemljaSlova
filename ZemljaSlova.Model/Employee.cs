using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Employee
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public string AccessLevel { get; set; } = null!;

        public virtual User User { get; set; } = null!;
    }
}
