using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class OrderItemUpdateRequest
    {
        public int? DiscountId { get; set; }

        public int? VoucherId { get; set; }
    }
}
