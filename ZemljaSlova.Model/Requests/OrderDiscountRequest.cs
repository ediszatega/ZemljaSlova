using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class OrderDiscountRequest
    {
        public List<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
        public string? DiscountCode { get; set; }
    }
} 