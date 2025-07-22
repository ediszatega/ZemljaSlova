import 'package:flutter/material.dart';

class SearchLoadingIndicator extends StatelessWidget {
  final bool isVisible;
  final String text;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const SearchLoadingIndicator({
    super.key,
    required this.isVisible,
    this.text = 'Pretražujem...',
    this.top,
    this.right = 20,
    this.bottom,
    this.left,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
} 