import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../models/product.dart';
import '../../state/cart_controller.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.currency});
  final Product product;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final qty = cart.qtyOf(product.id);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              ProductImage(product.imageUrl),
              Positioned(top: 8, left: 8, child: VegMark(isVeg: product.isVeg)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Text(product.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 4, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(money(product.price, currency),
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                if (!product.inStock)
                  const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text('Out of stock', style: TextStyle(fontSize: 12)))
                else if (qty == 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact),
                      onPressed: () => cart.add(product),
                      child: const Text('Add'),
                    ),
                  )
                else
                  QtyControl(
                      qty: qty,
                      onAdd: () => cart.add(product),
                      onRemove: () => cart.remove(product)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}