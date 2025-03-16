using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class OrderUpdateRequest
    {

        public int? DiscountId { get; set; }

        public decimal Amount { get; set; }

        public int? VoucherId { get; set; }
    }
}
