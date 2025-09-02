import 'package:flutter/material.dart';
import '../utils/image_utils.dart';

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
        final imageBytes = ImageUtils.base64ToImage(imageUrl!);
        
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
        return Image.network(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingIndicator(loadingProgress);
          },
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
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

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / 
              loadingProgress.expectedTotalBytes!
            : null,
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
}
