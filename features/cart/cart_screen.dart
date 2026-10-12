import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/widgets.dart';
import '../../models/store_settings.dart';
import '../../state/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final currency = context.watch<StoreSettings?>()?.currency ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.isEmpty
          ? const CenteredMessage('Your cart is empty.')
          : ContentWidth(
        maxWidth: 700,
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              for (final l in cart.lines)
                ListTile(
                  leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ProductImage(l.product.imageUrl))),
                  title: Text(l.product.displayName),
                  subtitle: Text(
                      '${money(l.product.price, currency)} × ${l.qty}'),
                  trailing: QtyControl(
                      qty: l.qty,
                      onAdd: () => cart.add(l.product),
                      onRemove: () => cart.remove(l.product)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(money(cart.total, currency),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: () => context.push('/checkout'),
                    child: const Text('Proceed to checkout')),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}