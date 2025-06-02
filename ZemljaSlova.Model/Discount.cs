using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Discount
    {
        public int Id { get; set; }

        public decimal DiscountPercentage { get; set; }

        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }

        public string? Code { get; set; }

        public string? Name { get; set; }

        public string? Description { get; set; }

        public DiscountScope Scope { get; set; }

        public int UsageCount { get; set; }

        public int? MaxUsage { get; set; }

        public bool IsActive { get; set; }

        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
    }

    public enum DiscountScope
    {
        Book = 1,
        Order = 2
    }
}
