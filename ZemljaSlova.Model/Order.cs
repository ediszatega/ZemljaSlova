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

        public string? PaymentIntentId { get; set; }

        public string? PaymentStatus { get; set; }

        public string? ShippingAddress { get; set; }

        public string? ShippingCity { get; set; }

        public string? ShippingPostalCode { get; set; }

        public string? ShippingCountry { get; set; }

        public string? ShippingPhoneNumber { get; set; }
        
        public string? ShippingEmail { get; set; }

        public virtual Discount? Discount { get; set; }

        public virtual Member Member { get; set; } = null!;

        public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();

        public virtual Voucher? Voucher { get; set; }
    }
}
