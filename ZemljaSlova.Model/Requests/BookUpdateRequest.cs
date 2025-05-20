using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class BookUpdateRequest
    {
        public string Title { get; set; } = null!;

        public string? Description { get; set; }

        public decimal Price { get; set; }

        public DateTime? DateOfPublish { get; set; }

        public int? Edition { get; set; }

        public string? Publisher { get; set; }

        public string BookPurpos { get; set; } = null!;

        public int NumberOfPages { get; set; }

        public decimal? Weight { get; set; }

        public string? Dimensions { get; set; }

        public string? Genre { get; set; }

        public string? Binding { get; set; }

        public byte[]? Image { get; set; }

        public string? Language { get; set; }

        public int? DiscountId { get; set; }

        public List<int> AuthorIds { get; set; } = new List<int>();
    }
}
