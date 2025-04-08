using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class OrderInsertRequest
    {
        public int MemberId { get; set; }

        public int? DiscountId { get; set; }

        public DateTime PurchasedAt { get; set; }

        public decimal Amount { get; set; }

        public int? VoucherId { get; set; }
    }
}
