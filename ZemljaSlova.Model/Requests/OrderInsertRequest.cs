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

        public string? PaymentIntentId { get; set; }

        public string? PaymentStatus { get; set; }

        // Payment Fields
        public string? PaymentMethodId { get; set; }
        
        // Shipping Address Fields
        public string? ShippingAddress { get; set; }
        public string? ShippingCity { get; set; }
        public string? ShippingPostalCode { get; set; }
        public string? ShippingCountry { get; set; }
        public string? ShippingPhoneNumber { get; set; }
        public string? ShippingEmail { get; set; }
    }
}
