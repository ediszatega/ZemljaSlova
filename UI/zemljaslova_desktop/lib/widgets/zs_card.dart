import 'package:flutter/material.dart';
import '../models/member.dart';
import '../screens/members_detail_overview.dart';

class ZSCard extends StatelessWidget {
  final Member member;
  
  const ZSCard({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MembersDetailOverview(member: member),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate heights - 75% for image, 25% for text
              final imageHeight = constraints.maxHeight * 0.75;
              final textHeight = constraints.maxHeight * 0.25;
              
              return Column(
                children: [
                  // Profile image - 75% of the card
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: member.profileImageUrl != null
                        ? Image.network(
                            member.profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
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
                            },
                          )
                        : Image.asset(
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
                          ),
                  ),
                  
                  // Text section - 25% of the card
                  Container(
                    height: textHeight,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Name
                        Text(
                          member.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: member.isActive 
                                ? Colors.green.withAlpha(20)
                                : Colors.red.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            member.isActive ? 'Aktivan' : 'Neaktivan',
                            style: TextStyle(
                              color: member.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
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
} 