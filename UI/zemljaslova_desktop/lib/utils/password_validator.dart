class PasswordValidator {
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    
    // Check minimum length
    if (password.length < 8) return false;
    
    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    
    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    // Check for no special characters
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) return false;
    
    return true;
  }
  
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Molimo unesite lozinku';
    }
    
    if (password.length < 8) {
      return 'Lozinka mora sadržavati najmanje 8 znakova';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Lozinka mora sadržavati najmanje jedno veliko slovo';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Lozinka mora sadržavati najmanje jedno malo slovo';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Lozinka mora sadržavati najmanje jednu cifru';
    }
    
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Lozinka ne smije sadržavati posebne znakove';
    }
    
    return null; // No error
  }
  
  static String getPasswordRequirementsMessage() {
    return 'Lozinka mora sadržavati najmanje 8 znakova, jedno veliko slovo, jedno malo slovo i jednu cifru. Posebni znakovi nisu dozvoljeni.';
  }
} 