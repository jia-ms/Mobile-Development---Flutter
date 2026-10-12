import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/admin_access.dart';
import '../../state/auth_controller.dart';

/// Simple intro page shown right after sign-in.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const path = '/welcome';

  static const _accent = Color(0xFFFFA98A); // matches your "Add" buttons

  @override
  Widget build(BuildContext context) {
    final profileName = context.watch<AuthController>().profile?.name;
    final user = FirebaseAuth.instance.currentUser;
    final name = (profileName?.isNotEmpty ?? false)
        ? profileName!
        : (user?.email?.split('@').first ?? 'there');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Ajji Ruchi'),
        actions: [
          AdminOnly(
            child: IconButton(
              tooltip: 'Admin panel',
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => context.go('/admin'),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Namaste, $name',
                    style: const TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 12),
                const Text(
                  'Mastering the Indian spices',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Home-style masala powders and instant mixes, made in small '
                      'batches from recipes passed down through generations.',
                  style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  ),
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.storefront),
                  label: const Text('Shop now', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 40),
                const Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _Feature(Icons.eco_outlined, 'No preservatives',
                        'Pure spices, ground fresh'),
                    _Feature(Icons.verified_outlined, 'FSSAI certified',
                        'Safe, licensed kitchen'),
                    _Feature(Icons.local_shipping_outlined, 'Fast delivery',
                        'Packed and shipped quickly'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: LandingScreen._accent, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}