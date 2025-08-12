using System;

namespace ZemljaSlova.Model.Requests
{
    public class BookReservationResponse
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public int BookId { get; set; }
        public DateTime ReservedAt { get; set; }
    }
}
