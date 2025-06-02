using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class OrderUpdateRequest
    {
        // TODO: handle discount
        public int? DiscountId { get; set; }

        // public string? DiscountCode { get; set; }

        public decimal Amount { get; set; }

        public int? VoucherId { get; set; }
    }
}
