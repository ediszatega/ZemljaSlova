class ErrorFormatter {
  // Removes the "Exception:" prefix from error messages
  static String formatException(String errorMessage) {
    if (errorMessage.startsWith('Exception: ')) {
      return errorMessage.substring('Exception: '.length);
    }
    return errorMessage;
  }
}
