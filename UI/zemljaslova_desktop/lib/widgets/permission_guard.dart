import 'package:flutter/material.dart';
import '../utils/authorization.dart';

class PermissionGuard extends StatelessWidget {
  final Widget child;
  final bool Function() permissionCheck;
  final Widget? fallback;

  const PermissionGuard({
    Key? key,
    required this.child,
    required this.permissionCheck,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (permissionCheck()) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

// Admin-only permission guards (only check what's admin-specific)
class AdminOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnly({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permissionCheck: () => Authorization.isAdmin,
      child: child,
      fallback: fallback,
    );
  }
}

class CanDeleteBooks extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const CanDeleteBooks({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permissionCheck: () => Authorization.canDeleteBooks(),
      child: child,
      fallback: fallback,
    );
  }
}

class CanDeleteUsers extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const CanDeleteUsers({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permissionCheck: () => Authorization.canDeleteUsers(),
      child: child,
      fallback: fallback,
    );
  }
}

class CanDeleteAuthors extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const CanDeleteAuthors({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permissionCheck: () => Authorization.canDeleteAuthors(),
      child: child,
      fallback: fallback,
    );
  }
}

class CanDeleteVouchers extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const CanDeleteVouchers({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permissionCheck: () => Authorization.canDeleteVouchers(),
      child: child,
      fallback: fallback,
    );
  }
} 