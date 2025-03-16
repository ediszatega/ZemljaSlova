﻿using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class TicketTypeTransactionInsertRequest
    {
        public byte ActivityTypeId { get; set; }

        public int TicketTypeId { get; set; }

        public int Quantity { get; set; }

        public DateTime CreatedAt { get; set; }

        public int? EmployeeId { get; set; }

        public int? MemberId { get; set; }

        public string? Data { get; set; }
    }
}
