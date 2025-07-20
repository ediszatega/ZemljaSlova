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

class MemberOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const MemberOnly({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permissionCheck: () => Authorization.canAccessMobileApp(),
      child: child,
      fallback: fallback,
    );
  }
} 