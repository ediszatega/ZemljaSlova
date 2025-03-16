using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class EmployeeUpsertRequest
    {
        public int UserId { get; set; }
        public string AccessLevel { get; set; } = null!;
    }
}
