using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class AdminChangePasswordRequest
    {
        public int UserId { get; set; }
        public string NewPassword { get; set; } = null!;
        public string NewPasswordConfirmation { get; set; } = null!;
    }
} 