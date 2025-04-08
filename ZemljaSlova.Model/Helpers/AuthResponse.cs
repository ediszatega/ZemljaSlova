namespace ZemljaSlova.Model.Helpers
{
    public class AuthResponse
    {
        public AuthResult Result { get; set; }
        public string Token { get; set; }
        public int UserId { get; set; }

        public string Role { get; set; }
    }
}
