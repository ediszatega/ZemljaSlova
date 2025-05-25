using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class VoucherMemberInsertRequest
    {
        public decimal Value { get; set; }

        public int MemberId { get; set; }
    }
} 