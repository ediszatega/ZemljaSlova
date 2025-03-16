using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class AuthorUpsertRequest
    {
        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        //public DateOnly? DateOfBirth { get; set; }

        //public string? Genre { get; set; }

        //public string? Biography { get; set; }
    }
}
