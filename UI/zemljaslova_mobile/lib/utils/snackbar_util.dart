import 'package:flutter/material.dart';

class SnackBarUtil {
  static void showTopSnackBar(
    BuildContext context, 
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Get screen height and safe area
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top;
    
    // Calculate bottom margin to position at top
    final bottomMargin = screenHeight - topPadding - 100; // 100 is approximate height for snackbar
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          maxLines: null, // Allow text to wrap to multiple lines
          overflow: TextOverflow.visible,
        ),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: topPadding + 16,
          left: 16,
          right: 16,
          bottom: bottomMargin > 0 ? bottomMargin : 16, // Fallback to normal bottom positioning
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: duration,
        dismissDirection: DismissDirection.up,
        padding: const EdgeInsets.all(16), // Add more padding for better text display
      ),
    );
  }
} 