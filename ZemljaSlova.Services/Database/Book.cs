using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class Book
{
    public int Id { get; set; }

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

    public int? AuthorId { get; set; }

    public virtual Author? Author { get; set; }

    public virtual ICollection<BookReservation> BookReservations { get; set; } = new List<BookReservation>();

    public virtual ICollection<BookTransaction> BookTransactions { get; set; } = new List<BookTransaction>();

    public virtual Discount? Discount { get; set; }

    public virtual ICollection<Favourite> Favourites { get; set; } = new List<Favourite>();

    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}
