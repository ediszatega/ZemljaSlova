using System;
using System.Collections.Generic;
using System.Text;

namespace ZemljaSlova.Model.Requests
{
    public partial class EventUpsertRequest
    {
        public string Title { get; set; } = null!;

        public string Description { get; set; } = null!;

        public string? Location { get; set; }

        public DateTime StartAt { get; set; }

        public DateTime EndAt { get; set; }

        public string? Organizer { get; set; }

        public string? Lecturers { get; set; }

        public byte[]? CoverImage { get; set; }

        public int? MaxNumberOfPeople { get; set; }
    }
}
