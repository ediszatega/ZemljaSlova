using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class EventSearchObject : BaseSearchObject
    {
        public bool IsTicketTypeIncluded { get; set; }
        public string? Name { get; set; }
        public string? SortBy { get; set; }
        public string? SortOrder { get; set; }
        
        // Filter properties
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
    }
}
