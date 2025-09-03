using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public partial class User
    {
        public int Id { get; set; }

        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string? Gender { get; set; }

        public string Email { get; set; } = null!;

        public string Password { get; set; } = null!;

        public byte[]? Image { get; set; }
    }
}
