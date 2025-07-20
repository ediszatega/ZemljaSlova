class Authorization {
  static String? email;
  static String? password;
  static int? userId;
  static String? role;
  static String? token;

  static void clear() {
    email = null;
    password = null;
    userId = null;
    role = null;
    token = null;
  }

  static bool get isMember => role == "member";
  
  static bool canAccessMobileApp() => isMember;
} 