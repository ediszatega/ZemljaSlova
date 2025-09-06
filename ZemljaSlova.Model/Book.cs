using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public enum BookPurpose
    {
        Sell = 1,
        Rent = 2
    }

    public class Book
    {
        public int Id { get; set; }

        public string Title { get; set; } = null!;

        public string? Description { get; set; }

        public decimal? Price { get; set; }

        public DateTime? DateOfPublish { get; set; }

        public int? Edition { get; set; }

        public string? Publisher { get; set; }

        public BookPurpose BookPurpose { get; set; }

        public int NumberOfPages { get; set; }

        public decimal? Weight { get; set; }

        public string? Dimensions { get; set; }

        public string? Genre { get; set; }

        public string? Binding { get; set; }

        public byte[]? Image { get; set; }

        public string? Language { get; set; }

        public int? DiscountId { get; set; }

        public virtual ICollection<Author> Authors { get; set; } = new List<Author>();

        public virtual ICollection<BookReservation> BookReservations { get; set; } = new List<BookReservation>();

        public virtual ICollection<Recommendation> Recommendations { get; set; } = new List<Recommendation>();

        public virtual Discount? Discount { get; set; }
        
        public int QuantityInStock { get; set; }
        
        public bool IsAvailable { get; set; }
        
        public decimal? DiscountedPrice 
        { 
            get 
            {
                if (BookPurpose != BookPurpose.Sell || Price == null || Discount == null)
                    return null;
                if (Discount.IsActive && 
                    Discount.StartDate <= DateTime.Now && 
                    Discount.EndDate >= DateTime.Now &&
                    (!Discount.MaxUsage.HasValue || Discount.UsageCount < Discount.MaxUsage.Value))
                {
                    return Price - (Price * (Discount.DiscountPercentage / 100));
                }
                return null;
            }
        }
    }
}
