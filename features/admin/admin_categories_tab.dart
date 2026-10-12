import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validators.dart';
import '../../core/widgets.dart';
import '../../data/catalog_repository.dart';
import '../../models/category.dart';

class AdminCategoriesTab extends StatelessWidget {
  const AdminCategoriesTab({super.key});

  Future<void> _edit(BuildContext context, [ProductCategory? existing]) async {
    final repo = context.read<CatalogRepository>();
    final form = GlobalKey<FormState>();
    final name = TextEditingController(text: existing?.name);
    final order = TextEditingController(text: (existing?.order ?? 0).toString());
    final image = TextEditingController(text: existing?.imageUrl);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'Add category' : 'Edit category'),
        content: Form(
          key: form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => Validators.required(v, 'Name')),
            const SizedBox(height: 10),
            TextFormField(
                controller: image,
                decoration: const InputDecoration(labelText: 'Image URL')),
            const SizedBox(height: 10),
            TextFormField(
                controller: order,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Display order'),
                validator: Validators.number),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              await repo.saveCategory(ProductCategory(
                id: existing?.id ?? '',
                name: name.text.trim(),
                imageUrl: image.text.trim(),
                order: int.parse(order.text.trim().split('.').first),
                active: existing?.active ?? true,
              ));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    name.dispose();
    order.dispose();
    image.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<List<ProductCategory>?>();
    final repo = context.read<CatalogRepository>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
      ),
      body: categories == null
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? const CenteredMessage('No categories yet.')
          : ContentWidth(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            for (final c in categories)
              ListTile(
                title: Text(c.name),
                subtitle: Text('Order ${c.order}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Switch(
                    value: c.active,
                    onChanged: (v) => repo.saveCategory(ProductCategory(
                        id: c.id,
                        name: c.name,
                        imageUrl: c.imageUrl,
                        order: c.order,
                        active: v)),
                  ),
                  IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(context, c)),
                  IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => repo.deleteCategory(c.id)),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}