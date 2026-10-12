import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import 'payment_method_selector.dart';

class OrderConfirmationArgs {
  const OrderConfirmationArgs({
    this.orderId,
    required this.total,
    required this.currency,
    required this.paymentMethod,
  });

  final String? orderId;
  final num total;
  final String currency;
  final PaymentMethod paymentMethod;
}

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.args});

  static const path = '/order-confirmed';

  /// Null when the page is refreshed (web drops `extra`) -> generic message.
  final OrderConfirmationArgs? args;

  @override
  Widget build(BuildContext context) {
    final a = args;
    final paid = a != null && a.paymentMethod != PaymentMethod.cod;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 96),
                const SizedBox(height: 16),
                Text('Order placed!',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text('Thank you for shopping with Ajji Ruchi.',
                    textAlign: TextAlign.center),
                if (a != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (a.orderId != null) _row('Order ID', a.orderId!),
                          _row('Amount', money(a.total, a.currency)),
                          _row('Payment', a.paymentMethod.label),
                          _row('Status',
                              paid ? 'Paid (demo)' : 'Pay on delivery'),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go('/orders'),
                    child: const Text('View my orders'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Continue shopping'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(v,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}