import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/auth_service.dart';
import '../../state/auth_controller.dart';
import '../../state/cart_controller.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.user == null) {
      return TextButton(
          onPressed: () => context.go('/login'), child: const Text('Login'));
    }
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle_outlined),
      tooltip: 'Account',
      onSelected: (v) async {
        switch (v) {
          case 'orders':
            context.push('/orders');
          case 'admin':
            context.push('/admin');
          case 'logout':
            context.read<CartController>().clear();
            await context.read<AuthService>().signOut();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Text(auth.profile?.name.isNotEmpty == true
              ? auth.profile!.name
              : (auth.user?.email ?? '')),
        ),
        const PopupMenuItem(value: 'orders', child: Text('My orders')),
        if (auth.isAdmin)
          const PopupMenuItem(value: 'admin', child: Text('Admin panel')),
        const PopupMenuItem(value: 'logout', child: Text('Log out')),
      ],
    );
  }
}
