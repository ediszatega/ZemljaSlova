using System.ComponentModel.DataAnnotations;

namespace ZemljaSlova.Model.Requests
{
    public class CreatePaymentIntentRequest
    {
        [Required]
        public decimal Amount { get; set; }
        
        public string Currency { get; set; } = "bam";
    }
    
    public class PaymentIntentResponse
    {
        public string ClientSecret { get; set; } = null!;
        public string PaymentIntentId { get; set; } = null!;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "bam";
        public string Status { get; set; } = null!;
    }
}
