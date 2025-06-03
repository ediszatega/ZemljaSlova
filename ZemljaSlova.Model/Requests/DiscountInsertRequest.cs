using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class DiscountInsertRequest
    {
        public decimal DiscountPercentage { get; set; }

        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }

        public string? Code { get; set; }

        public string Name { get; set; } = null!;

        public string? Description { get; set; }

        public DiscountScope Scope { get; set; }

        public int? MaxUsage { get; set; }

        // For book-specific discounts (null for order-level discounts)
        public List<int>? BookIds { get; set; }
    }
} 