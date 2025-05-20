using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database
{
    public partial class BookAuthor
    {
        public int BookId { get; set; }

        public int AuthorId { get; set; }

        public virtual Book Book { get; set; }
        
        public virtual Author Author { get; set; }
    }
} 