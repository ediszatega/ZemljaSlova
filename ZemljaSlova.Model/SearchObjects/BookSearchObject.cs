using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.SearchObjects
{
    public class BookSearchObject : BaseSearchObject
    {
        public BookPurpose? BookPurpose { get; set; }
        
        // Include
        public bool IsAuthorIncluded { get; set; }

        // Search
        public string? Title { get; set; }

        // Sort
        public string? SortBy { get; set; }
        public string? SortOrder { get; set; }
        
        // Filter
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public int? AuthorId { get; set; }
        public bool? IsAvailable { get; set; }
    }
}
