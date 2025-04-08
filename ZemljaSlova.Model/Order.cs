using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Order
    {
        public int Id { get; set; }

        public int MemberId { get; set; }

        public int? DiscountId { get; set; }

        public DateTime PurchasedAt { get; set; }

        public decimal Amount { get; set; }

        public int? VoucherId { get; set; }

        public virtual Discount? Discount { get; set; }

        public virtual Member Member { get; set; } = null!;

        public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();

        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

        public virtual Voucher? Voucher { get; set; }
    }
}
