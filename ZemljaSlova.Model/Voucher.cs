using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Voucher
    {
        public int Id { get; set; }

        public decimal Value { get; set; }

        public string Code { get; set; } = null!;

        public bool IsUsed { get; set; }

        public DateTime ExpirationDate { get; set; }

        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
    }
}
