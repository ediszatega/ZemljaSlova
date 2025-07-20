class UserInfo {
  // For desktop app, we store employee info since it's employee-focused
  static Map<String, dynamic>? currentEmployee;
  
  static void clear() {
    currentEmployee = null;
  }
  
  static String? get firstName => currentEmployee?['firstName'];
  static String? get lastName => currentEmployee?['lastName'];
  static String? get email => currentEmployee?['email'];
  static String? get accessLevel => currentEmployee?['accessLevel'];
  static String? get fullName => 
      (firstName != null && lastName != null) ? '$firstName $lastName' : null;
} 