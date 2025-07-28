using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class VoucherSearchObject : BaseSearchObject
    {
        public int? MemberId { get; set; }
        public bool? IsUsed { get; set; }
        public string? Code { get; set; }
        public string? Name { get; set; }
        
        // Filter
        public decimal? MinValue { get; set; }
        public decimal? MaxValue { get; set; }
        public string? VoucherType { get; set; } // "promotional" or "purchased"
        public DateTime? ExpirationDateFrom { get; set; }
        public DateTime? ExpirationDateTo { get; set; }
    }
}
