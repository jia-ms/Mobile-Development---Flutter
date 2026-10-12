import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/store_settings.dart';
import '../../state/cart_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.id});
  final String id;
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _photo = 0;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<List<Product>?>();
    final categories = context.watch<List<ProductCategory>?>() ?? const [];
    final currency = context.watch<StoreSettings?>()?.currency ?? '';
    final cart = context.watch<CartController>();

    Widget body;
    if (products == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final matches = products.where((p) => p.id == widget.id);
      if (matches.isEmpty) {
        body = const CenteredMessage('This product is no longer available.');
      } else {
        final p = matches.first;
        final qty = cart.qtyOf(p.id);
        final photo = p.images.isEmpty ? '' : p.images[_photo.clamp(0, p.images.length - 1)];
        final related = products
            .where((o) =>
        o.id != p.id && o.categoryIds.any(p.categoryIds.contains))
            .take(6)
            .toList();

        body = SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ContentWidth(
            maxWidth: 800,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AspectRatio(
                aspectRatio: 1.4,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ProductImage(photo)),
              ),
              if (p.images.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 64,
                    child: ListView(scrollDirection: Axis.horizontal, children: [
                      for (var i = 0; i < p.images.length; i++)
                        GestureDetector(
                          onTap: () => setState(() => _photo = i),
                          child: Container(
                            width: 64,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: i == _photo
                                      ? AppColors.accent
                                      : Colors.transparent,
                                  width: 2),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: ProductImage(p.images[i])),
                          ),
                        ),
                    ]),
                  ),
                ),
              const SizedBox(height: 16),
              Row(children: [
                VegMark(isVeg: p.isVeg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(p.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ]),
              if (p.weight.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(p.weight)),
              if (p.rating > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('★' * p.rating.round(),
                      style: const TextStyle(color: Colors.amber)),
                ),
              const SizedBox(height: 8),
              Text(money(p.price, currency),
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              if (p.categoryIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, children: [
                  for (final c in categories.where((c) => p.categoryIds.contains(c.id)))
                    Chip(
                        label: Text(c.name),
                        visualDensity: VisualDensity.compact),
                ]),
              ],
              if (p.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(p.description),
              ],
              const SizedBox(height: 20),
              if (!p.inStock)
                const Text('Currently out of stock')
              else if (qty == 0)
                FilledButton.icon(
                  onPressed: () => cart.add(p),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to cart'),
                )
              else
                Row(children: [
                  QtyControl(
                      qty: qty,
                      onAdd: () => cart.add(p),
                      onRemove: () => cart.remove(p)),
                  const Spacer(),
                  FilledButton(
                      onPressed: () => context.push('/cart'),
                      child: const Text('Go to cart')),
                ]),
              if (related.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('You may also like',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 140,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    for (final o in related)
                      InkWell(
                        onTap: () => context.pushReplacement('/product/${o.id}'),
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: ProductImage(o.imageUrl))),
                                const SizedBox(height: 4),
                                Text(o.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12)),
                              ]),
                        ),
                      ),
                  ]),
                ),
              ],
            ]),
          ),
        );
      }
    }
    return Scaffold(appBar: AppBar(), body: body);
  }
}