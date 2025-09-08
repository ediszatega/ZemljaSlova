import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import 'dart:convert';

class ImageDisplayWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final IconData fallbackIcon;
  final String fallbackText;
  final Color? backgroundColor;

  const ImageDisplayWidget({
    Key? key,
    this.imageUrl,
    this.width = 120,
    this.height = 150,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.fallbackIcon = Icons.image,
    this.fallbackText = 'Nema slike',
    this.backgroundColor,
  }) : super(key: key);

  const ImageDisplayWidget.book({
    Key? key,
    String? imageUrl,
    double width = 120,
    double height = 150,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Color? backgroundColor,
  }) : this(
          key: key,
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
          placeholder: placeholder,
          fallbackIcon: Icons.book,
          fallbackText: 'Nema slike',
          backgroundColor: backgroundColor,
        );

  const ImageDisplayWidget.profile({
    Key? key,
    String? imageUrl,
    double width = 120,
    double height = 150,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Color? backgroundColor,
  }) : this(
          key: key,
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
          placeholder: placeholder,
          fallbackIcon: Icons.person,
          fallbackText: 'Nema slike',
          backgroundColor: backgroundColor,
        );

  const ImageDisplayWidget.event({
    Key? key,
    String? imageUrl,
    double width = 120,
    double height = 150,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Color? backgroundColor,
  }) : this(
          key: key,
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
          placeholder: placeholder,
          fallbackIcon: Icons.event,
          fallbackText: 'Nema slike',
          backgroundColor: backgroundColor,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: backgroundColor ?? Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (placeholder != null && (imageUrl == null || imageUrl!.isEmpty)) {
      return placeholder!;
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('data:image/')) {
        final imageBytes = _base64ToImage(imageUrl!);
        
        if (imageBytes != null) {
          return Image.memory(
            imageBytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          );
        }
      } else if (imageUrl!.startsWith('http')) {
        // Add cache-busting parameter to force reload updated images
        String finalUrl = imageUrl!;
        if (!finalUrl.contains('?')) {
          finalUrl += '?t=${DateTime.now().millisecondsSinceEpoch}';
        } else {
          finalUrl += '&t=${DateTime.now().millisecondsSinceEpoch}';
        }
        
        return CachedNetworkImage(
          imageUrl: finalUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildLoadingIndicator(),
          errorWidget: (context, url, error) => _buildFallback(),
        );
      } else {
        return Image.asset(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    }
    
    return _buildFallback();
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              fallbackIcon,
              size: (width * 0.3).clamp(20.0, 60.0),
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              fallbackText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Uint8List? _base64ToImage(String base64String) {
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
}
