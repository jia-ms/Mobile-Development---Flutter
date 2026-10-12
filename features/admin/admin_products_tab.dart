import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/validators.dart';
import '../../core/widgets.dart';
import '../../data/catalog_repository.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/store_settings.dart';

class AdminProductsTab extends StatelessWidget {
  const AdminProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<List<Product>?>();
    final categories = context.watch<List<ProductCategory>?>() ?? const [];
    final currency = context.watch<StoreSettings?>()?.currency ?? '';
    final repo = context.read<CatalogRepository>();

    String catNames(List<String> ids) {
      final names =
      categories.where((c) => ids.contains(c.id)).map((c) => c.name);
      return names.isEmpty ? '—' : names.join(', ');
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
            context: context,
            builder: (_) => ProductFormDialog(categories: categories)),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: products == null
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const CenteredMessage(
          'No products yet. Add one, or import sample data (cloud icon).')
          : ContentWidth(
        maxWidth: 800,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            for (final p in products)
              ListTile(
                leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ProductImage(p.imageUrl))),
                title: Text(p.displayName),
                subtitle: Text(
                    '${money(p.price, currency)} · ${catNames(p.categoryIds)}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Switch(
                    value: p.inStock,
                    onChanged: (v) => repo.setInStock(p.id, v),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        showDialog(
                            context: context,
                            builder: (_) => ProductFormDialog(
                                categories: categories, product: p));
                      } else {
                        final ok = await _confirmDelete(context, p.name);
                        if (ok) await repo.deleteProduct(p.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Delete "$name"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete')),
          ],
        ),
      ) ??
          false;
}

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, required this.categories, this.product});
  final List<ProductCategory> categories;
  final Product? product;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name);
  late final _weight = TextEditingController(text: widget.product?.weight);
  late final _desc = TextEditingController(text: widget.product?.description);
  late final _price =
  TextEditingController(text: widget.product?.price.toString());
  late final _images =
  TextEditingController(text: (widget.product?.images ?? []).join('\n'));
  late final _rating =
  TextEditingController(text: (widget.product?.rating ?? 0).toString());
  late final _sort =
  TextEditingController(text: (widget.product?.sortOrder ?? 0).toString());
  late final Set<String> _categoryIds = {...?widget.product?.categoryIds};
  late bool _inStock = widget.product?.inStock ?? true;
  late bool _featured = widget.product?.featured ?? false;
  late bool _isVeg = widget.product?.isVeg ?? true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _weight, _desc, _price, _images, _rating, _sort]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_categoryIds.isEmpty) {
      setState(() => _error = 'Select at least one category');
      return;
    }
    final repo = context.read<CatalogRepository>();
    final nav = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await repo.saveProduct(Product(
        id: widget.product?.id ?? '',
        name: _name.text.trim(),
        weight: _weight.text.trim(),
        description: _desc.text.trim(),
        categoryIds: _categoryIds.toList(),
        images: _images.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        price: num.parse(_price.text.trim()),
        inStock: _inStock,
        featured: _featured,
        isVeg: _isVeg,
        rating: double.tryParse(_rating.text.trim()) ?? 0,
        sortOrder: int.tryParse(_sort.text.trim()) ?? 0,
      ));
      nav.pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Save failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.product == null ? 'Add product' : 'Edit product'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => Validators.required(v, 'Name')),
            const SizedBox(height: 10),
            TextFormField(
                controller: _weight,
                decoration: const InputDecoration(
                    labelText: 'Pack size', helperText: 'e.g. 100gm, 200gm')),
            const SizedBox(height: 10),
            TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: Validators.number),
            const SizedBox(height: 10),
            TextFormField(
                controller: _desc,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Categories',
                    style: Theme.of(context).textTheme.labelLarge)),
            Wrap(spacing: 8, children: [
              for (final c in widget.categories)
                FilterChip(
                  label: Text(c.name),
                  selected: _categoryIds.contains(c.id),
                  onSelected: (v) => setState(() =>
                  v ? _categoryIds.add(c.id) : _categoryIds.remove(c.id)),
                ),
            ]),
            const SizedBox(height: 10),
            TextFormField(
                controller: _images,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: 'Photo URLs',
                    helperText: 'One per line. The first is the main photo.')),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextFormField(
                    controller: _rating,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: 'Rating (0-5)')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                    controller: _sort,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: 'Sort order')),
              ),
            ]),
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vegetarian'),
                value: _isVeg,
                onChanged: (v) => setState(() => _isVeg = v)),
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('In stock'),
                value: _inStock,
                onChanged: (v) => setState(() => _inStock = v)),
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Featured'),
                value: _featured,
                onChanged: (v) => setState(() => _featured = v)),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!,
                    style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ]),
        ),
      ),
    ),
    actions: [
      TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel')),
      FilledButton(
          onPressed: _busy ? null : _save, child: const Text('Save')),
    ],
  );
}