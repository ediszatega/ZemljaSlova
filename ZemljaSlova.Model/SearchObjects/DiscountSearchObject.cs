using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class DiscountSearchObject : BaseSearchObject
    {
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
        public DateTime? EndDateFrom { get; set; }
        public DateTime? EndDateTo { get; set; }
        public bool? IsActive { get; set; }
        public DiscountScope? Scope { get; set; }
        public decimal? MinPercentage { get; set; }
        public decimal? MaxPercentage { get; set; }
        public string? Code { get; set; }
        public bool? HasUsageLimit { get; set; }
        public int? BookId { get; set; } // Find discounts applicable to specific book
    }
}
