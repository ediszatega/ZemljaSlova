using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class VoucherUpsertRequest
    {
        public decimal Value { get; set; }

        public string Code { get; set; } = null!;

        public bool IsUsed { get; set; }

        public DateTime ExpirationDate { get; set; }
    }
}
