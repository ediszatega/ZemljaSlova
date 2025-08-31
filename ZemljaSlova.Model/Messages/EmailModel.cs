using System;

namespace ZemljaSlova.Model.Messages
{
    public class EmailModel
    {
        public string To { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public string? From { get; set; }
        public DateTime? SentDate { get; set; } = DateTime.UtcNow;
    }
}
