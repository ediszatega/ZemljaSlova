using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class RefreshTokenRequest
    {
        public string Token { get; set; } = null!;
    }
}
