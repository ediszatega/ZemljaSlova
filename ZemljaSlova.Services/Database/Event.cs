using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class Event
{
    public int Id { get; set; }

    public string Title { get; set; } = null!;

    public string Description { get; set; } = null!;

    public string? Location { get; set; }

    public DateTime StartAt { get; set; }

    public DateTime EndAt { get; set; }

    public string? Organizer { get; set; }

    public string? Lecturers { get; set; }

    public byte[]? CoverImage { get; set; }

    public int? MaxNumberOfPeople { get; set; }

    public virtual ICollection<TicketType> TicketTypes { get; set; } = new List<TicketType>();
}
