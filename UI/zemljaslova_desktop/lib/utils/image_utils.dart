import 'dart:typed_data';
import 'dart:convert';

class ImageUtils {
  // Maximum image size in bytes (5MB)
  static const int maxImageSize = 5 * 1024 * 1024;
  
  // Maximum image dimensions
  static const int maxWidth = 1920;
  static const int maxHeight = 1080;
  
  // Minimum image dimensions
  static const int minWidth = 200;
  static const int minHeight = 200;
  
  // Supported image formats
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Validates if the image file is acceptable
  static String? validateImage(Uint8List? imageBytes, String? fileName) {
    if (imageBytes == null || imageBytes.isEmpty) {
      return null;
    }
    
    // Check file size
    if (imageBytes.length > maxImageSize) {
      return 'Slika je prevelika. Maksimalna veličina je 5MB.';
    }
    
    // Check file extension
    if (fileName != null) {
      final extension = fileName.toLowerCase().split('.').last;
      if (!supportedFormats.contains(extension)) {
        return 'Nepodržan format slike. Podržani formati: ${supportedFormats.join(', ')}';
      }
    }
    
    // Check if it starts with image file signature
    try {
      if (imageBytes.length < 8) {
        return 'Fajl nije validna slika.';
      }
      
      // Check for common image headers
      final header = imageBytes.take(8).toList();
      bool isValidImage = false;
      
      // JPEG
      if (header.length >= 2 && header[0] == 0xFF && header[1] == 0xD8) {
        isValidImage = true;
      }
      // PNG
      else if (header.length >= 8 && 
               header[0] == 0x89 && header[1] == 0x50 && 
               header[2] == 0x4E && header[3] == 0x47 &&
               header[4] == 0x0D && header[5] == 0x0A &&
               header[6] == 0x1A && header[7] == 0x0A) {
        isValidImage = true;
      }
      // WebP
      else if (header.length >= 4 && 
               header[0] == 0x52 && header[1] == 0x49 &&
               header[2] == 0x46 && header[3] == 0x46) {
        isValidImage = true;
      }
      
      if (!isValidImage) {
        return 'Fajl nije validna slika.';
      }
      
    } catch (e) {
      return 'Greška prilikom validacije slike.';
    }
    
    return null; // Valid image
  }
  
  // Image processing
  static Uint8List? processImage(Uint8List imageBytes, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) {
    return imageBytes;
  }
  
  static String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }
  
  static Uint8List? base64ToImage(String base64String) {
    try {
      // Remove data URL prefix if present
      String cleanBase64 = base64String;
      if (base64String.startsWith('data:image/')) {
        final commaIndex = base64String.indexOf(',');
        if (commaIndex != -1) {
          cleanBase64 = base64String.substring(commaIndex + 1);
        }
      }
      
      return base64Decode(cleanBase64);
    } catch (e) {
      return null;
    }
  }
  
  // Creates a data URL from image bytes
  static String createDataUrl(Uint8List imageBytes, {String mimeType = 'image/jpeg'}) {
    final base64String = base64Encode(imageBytes);
    return 'data:$mimeType;base64,$base64String';
  }
  
  // Gets the fallback image path for books
  static String getBookFallbackImagePath() {
    return 'assets/book_placeholder.jpg';
  }
  
  // Creates a placeholder image data URL
  static String createPlaceholderDataUrl() {
    // Return a simple gray placeholder
    return 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjI1MCIgdmlld0JveD0iMCAwIDIwMCAyNTAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIyMDAiIGhlaWdodD0iMjUwIiBmaWxsPSIjRjNGNEY2Ii8+CjxwYXRoIGQ9Ik0xMDAgMTEwVjE0MEgxMzBWMTEwSDEwMFoiIGZpbGw9IiM5Q0E0QUYiLz4KPHN2ZyBpZD0iYm9vayIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8cGF0aCBkPSJNNCAySDIwVjIySDRWMloiIGZpbGw9IiM2Mzc0OEEiIGZpbGwtb3BhY2l0eT0iMC4xIi8+CjxwYXRoIGQ9Ik02IDRIMThWMjBINlY0WiIgZmlsbD0iIzk0QTNBOCIvPgo8L3N2Zz4KPC9zdmc+';
  }
}
