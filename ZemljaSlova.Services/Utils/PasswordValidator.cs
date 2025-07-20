using System;
using System.Linq;

namespace ZemljaSlova.Services.Utils
{
    public static class PasswordValidator
    {
        public static bool IsValidPassword(string password)
        {
            if (string.IsNullOrEmpty(password))
                return false;
                
            // Check minimum length
            if (password.Length < 8)
                return false;
                
            // Check for at least one uppercase letter
            if (!password.Any(char.IsUpper))
                return false;
                
            // Check for at least one lowercase letter
            if (!password.Any(char.IsLower))
                return false;
                
            // Check for at least one digit
            if (!password.Any(char.IsDigit))
                return false;
                
            // Check for no special characters
            if (password.Any(c => !char.IsLetterOrDigit(c)))
                return false;
                
            return true;
        }

        public static string GetPasswordRequirementsMessage()
        {
            return "Password must be at least 8 characters long and contain a combination of uppercase letters, lowercase letters, and numbers. Special characters are not allowed.";
        }
    }
} 