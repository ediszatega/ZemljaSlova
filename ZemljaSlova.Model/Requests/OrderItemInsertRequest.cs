using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class OrderItemInsertRequest
    {
        public int? BookId { get; set; }

        public int? TicketTypeId { get; set; }

        public int? MembershipId { get; set; }

        public int? VoucherId { get; set; }

        public int Quantity { get; set; }

        public int? DiscountId { get; set; }

        public int OrderId { get; set; }
    }
}
