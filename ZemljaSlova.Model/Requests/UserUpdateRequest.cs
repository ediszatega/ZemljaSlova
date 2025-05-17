using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class UserUpdateRequest
    {
        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string? Gender { get; set; }

        public string Email { get; set; } = null!;
    }
}
