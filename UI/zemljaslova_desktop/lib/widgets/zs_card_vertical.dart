import 'package:flutter/material.dart';

class ZSCardVertical extends StatelessWidget {
  // Required parameters
  final String title;
  final String organizer;
  final String date;
  final Widget image;
  final String price;
  
  // Optional parameters
  final VoidCallback? onTap;
  
  const ZSCardVertical({
    super.key,
    required this.title,
    required this.organizer,
    required this.date,
    required this.image,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Image (wider)
              SizedBox(
                width: 260,
                child: image,
              ),
              
              // Right side - Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top section - Title and organizer
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            
                            // Organizer
                            Text(
                              organizer,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Bottom section - Date and price
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Date (now above price)
                            Text(
                              'Datum: $date',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            
                            // Price tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: price == 'Besplatno' 
                                    ? Colors.green.shade50
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                price,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: price == 'Besplatno' ? Colors.green : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Factory method to create a card from an event
  static Widget fromEvent(
    BuildContext context, 
    dynamic event, 
    {VoidCallback? onTap}
  ) {
    // Create image widget from event's image
    Widget imageWidget;
    if (event.imageUrl != null) {
      imageWidget = Image.network(
        event.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackEventImage();
        },
      );
    } else {
      imageWidget = _buildFallbackEventImage();
    }
    
    // Format price text
    String priceText;
    if (event.price == 0) {
      priceText = 'Besplatno';
    } else {
      priceText = '${event.price} KM';
    }
    
    return ZSCardVertical(
      title: event.title,
      organizer: event.organizer,
      date: event.date,
      image: imageWidget,
      price: priceText,
      onTap: onTap,
    );
  }
  
  // Helper method for fallback event image
  static Widget _buildFallbackEventImage() {
    return Image.asset(
      'assets/images/no_image.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.event,
            size: 60,
            color: Colors.black54,
          ),
        );
      },
    );
  }
} 