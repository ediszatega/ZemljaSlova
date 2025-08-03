using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public class BookTransactionUpdateRequest
    {
        public byte ActivityTypeId { get; set; }

        public int BookId { get; set; }

        public int Quantity { get; set; }

        public string? Data { get; set; }
    }
} 