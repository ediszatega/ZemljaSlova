import 'package:flutter/material.dart';

class ZSCard extends StatelessWidget {
  // Required parameters
  final String title;
  final Widget image;
  
  // Optional parameters
  final String? subtitle;
  final String? additionalText;
  final bool? isActive;
  final VoidCallback? onTap;
  final double imageHeightRatio;
  final double contentHeightRatio;
  
  const ZSCard({
    super.key,
    required this.title,
    required this.image,
    this.subtitle,
    this.additionalText,
    this.isActive,
    this.onTap,
    this.imageHeightRatio = 0.75,
    this.contentHeightRatio = 0.25,
  }) : assert(imageHeightRatio + contentHeightRatio == 1.0, 
         "imageHeightRatio + contentHeightRatio must equal 1.0");

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate heights based on provided ratios
              final imageHeight = constraints.maxHeight * imageHeightRatio;
              final contentHeight = constraints.maxHeight * contentHeightRatio;
              
              return Column(
                children: [
                  // Image section
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: image,
                  ),
                  
                  // Content section
                  Container(
                    height: contentHeight,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        if (subtitle != null) ...[
                          //const SizedBox(height: 1),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        if (additionalText != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            additionalText!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        // Status indicator (if provided)
                        if (isActive != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive! 
                                  ? Colors.green.withAlpha(20)
                                  : Colors.red.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive! ? 'Aktivan' : 'Neaktivan',
                              style: TextStyle(
                                color: isActive! ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  // Factory method to create a card from a member
  static Widget fromMember(
    BuildContext context, 
    dynamic member, 
    {VoidCallback? onTap}
  ) {
    // Create image widget from member's profile image
    Widget imageWidget;
    if (member.profileImageUrl != null) {
      imageWidget = Image.network(
        member.profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      );
    } else {
      imageWidget = _buildFallbackImage();
    }
    
    return ZSCard(
      title: member.fullName,
      image: imageWidget,
      isActive: member.isActive,
      onTap: onTap,
    );
  }
  
  // Helper method for fallback image
  static Widget _buildFallbackImage() {
    return Image.asset(
      'assets/images/no_profile_image.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.person,
            size: 120,
            color: Colors.black54,
          ),
        );
      },
    );
  }
  
  // Factory method to create a card from a book
  static Widget fromBook(
    BuildContext context, 
    dynamic book, 
    {VoidCallback? onTap}
  ) {
    // Create image widget from book's cover image
    Widget imageWidget;
    if (book.coverImageUrl != null) {
      imageWidget = Image.network(
        book.coverImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackBookImage();
        },
      );
    } else {
      imageWidget = _buildFallbackBookImage();
    }
    
    return ZSCard(
      title: book.title,
      subtitle: book.author,
      additionalText: '${book.price.toStringAsFixed(2)} KM',
      image: imageWidget,
      onTap: onTap,
    );
  }
  
  // Helper method for fallback book image
  static Widget _buildFallbackBookImage() {
    return Image.asset(
      'assets/images/no_image.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.book,
            size: 120,
            color: Colors.black54,
          ),
        );
      },
    );
  }

  // Factory method to create a card from an author
  static Widget fromAuthor(
    BuildContext context, 
    dynamic author, 
    {VoidCallback? onTap}
  ) {
    // Create image widget using fallback since author doesn't have profile image
    Widget imageWidget = _buildFallbackAuthorImage();
    
    // Additional info to display - genre if available
    String? subtitle = author.genre != null ? author.genre : null;
    
    return ZSCard(
      title: author.fullName,
      subtitle: subtitle,
      image: imageWidget,
      onTap: onTap,
    );
  }
  
  // Helper method for fallback author image
  static Widget _buildFallbackAuthorImage() {
    return Image.asset(
      'assets/images/no_profile_image.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.white,
          child: const Icon(
            Icons.person,
            size: 120,
            color: Colors.black54,
          ),
        );
      },
    );
  }
  
  // Factory method to create a card from an employee
  static Widget fromEmployee(
    BuildContext context, 
    dynamic employee, 
    {VoidCallback? onTap}
  ) {
    // Create image widget from employee's profile image
    Widget imageWidget;
    if (employee.profileImageUrl != null) {
      imageWidget = Image.network(
        employee.profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      );
    } else {
      imageWidget = _buildFallbackImage();
    }
    
    return ZSCard(
      title: employee.fullName,
      subtitle: employee.accessLevel,
      image: imageWidget,
      onTap: onTap,
    );
  }
} 