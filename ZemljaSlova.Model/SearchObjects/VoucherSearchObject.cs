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
        public DateTime? ExpirationDateFrom { get; set; }
        public DateTime? ExpirationDateTo { get; set; }
        public string? Name { get; set; }
    }
}
