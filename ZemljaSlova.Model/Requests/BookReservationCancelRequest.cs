using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class BookReservationCancelRequest
    {
        public int ReservationId { get; set; }
        public int MemberId { get; set; }
    }
}
