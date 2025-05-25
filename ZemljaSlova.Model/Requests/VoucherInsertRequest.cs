using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class VoucherAdminInsertRequest
    {
        public decimal Value { get; set; }

        public DateTime ExpirationDate { get; set; }

        public string? Code { get; set; } // Admin defined - auto-generated if not provided
    }
} 