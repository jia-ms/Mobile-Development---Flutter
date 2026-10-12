import 'package:flutter/material.dart';

import '../../data/seed_service.dart';
import 'admin_categories_tab.dart';
import 'admin_orders_tab.dart';
import 'admin_products_tab.dart';
import 'admin_settings_tab.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<void> _seed(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Import sample data?'),
        content: const Text(
            'Loads settings, categories, products and reviews from '
            'assets/seed/seed_data.json. Existing items with the same IDs are overwritten.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await SeedService.run();
      messenger.showSnackBar(const SnackBar(content: Text('Sample data imported')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Admin'),
            actions: [
              IconButton(
                tooltip: 'Import sample data',
                icon: const Icon(Icons.cloud_upload_outlined),
                onPressed: () => _seed(context),
              ),
            ],
            bottom: const TabBar(isScrollable: true, tabs: [
              Tab(text: 'Products'),
              Tab(text: 'Categories'),
              Tab(text: 'Orders'),
              Tab(text: 'Store settings'),
            ]),
          ),
          body: const TabBarView(children: [
            AdminProductsTab(),
            AdminCategoriesTab(),
            AdminOrdersTab(),
            AdminSettingsTab(),
          ]),
        ),
      );
}
