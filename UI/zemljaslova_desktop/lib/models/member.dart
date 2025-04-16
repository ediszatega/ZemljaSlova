class Member {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final bool isActive;
  final String? profileImageUrl;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isActive,
    this.profileImageUrl,
  });

  String get fullName => '$firstName $lastName';

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      isActive: json['isActive'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
    };
  }
} 