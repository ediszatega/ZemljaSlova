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

  static bool get isEmployee => role == "employee";
  static bool get isMember => role == "member";
  static bool get isAdmin => role == "admin";
  
  // Admin-only permissions
  static bool canDeleteBooks() => isAdmin;
  static bool canDeleteUsers() => isAdmin;
  static bool canDeleteAuthors() => isAdmin;
  static bool canDeleteVouchers() => isAdmin;
  static bool canDeleteDiscounts() => isAdmin;
  static bool canManageEmployees() => isAdmin;
  static bool canViewAdminFeatures() => isAdmin;
  static bool canCreateAdminVouchers() => isAdmin;
  static bool canCleanupExpiredDiscounts() => isAdmin;
}