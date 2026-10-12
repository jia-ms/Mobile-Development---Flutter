import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_controller.dart';

/// Shows its child only when the signed-in user's profile has role == 'admin'
/// (same check the router uses via AuthController.isAdmin).
class AdminOnly extends StatelessWidget {
  const AdminOnly({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return context.watch<AuthController>().isAdmin
        ? child
        : const SizedBox.shrink();
  }
}