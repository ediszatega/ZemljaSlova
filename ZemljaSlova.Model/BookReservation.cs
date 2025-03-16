using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model
{
    public class BookReservation
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public int BookId { get; set; }

        public DateTime ReservedAt { get; set; }
    }
}
