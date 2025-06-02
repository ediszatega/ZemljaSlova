using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class OrderInsertRequest
    {
        public int MemberId { get; set; }

        // TODO: handle discount
        public int? DiscountId { get; set; }

        // public string? DiscountCode { get; set; }

        public DateTime PurchasedAt { get; set; }

        public decimal Amount { get; set; }

        public int? VoucherId { get; set; }
    }
}
