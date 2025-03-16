using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class Discount
    {
        public int Id { get; set; }

        public decimal DiscountAmount { get; set; }

        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }

        public string Type { get; set; } = null!;

        public virtual ICollection<Book> Books { get; set; } = new List<Book>();

        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
    }
}
