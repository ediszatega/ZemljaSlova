class UserInfo {
  // For mobile app, we only need member info
  static Map<String, dynamic>? currentMember;
  
  static void clear() {
    currentMember = null;
  }
  
  static String? get firstName => currentMember?['firstName'];
  static String? get lastName => currentMember?['lastName'];
  static String? get email => currentMember?['email'];
  static String? get fullName => 
      (firstName != null && lastName != null) ? '$firstName $lastName' : null;
} 