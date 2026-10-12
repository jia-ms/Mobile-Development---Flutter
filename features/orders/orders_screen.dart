import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/links.dart';
import '../../core/widgets.dart';
import '../../data/order_repository.dart';
import '../../models/store_order.dart';
import '../../models/store_settings.dart';
import '../../state/auth_controller.dart';
import 'order_tile.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final Stream<List<StoreOrder>> _stream = context
      .read<OrderRepository>()
      .userOrders(context.read<AuthController>().user!.uid);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StoreSettings?>();
    final currency = settings?.currency ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: StreamBuilder<List<StoreOrder>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) return const CenteredMessage('Could not load orders.');
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snap.data!;
          if (orders.isEmpty) return const CenteredMessage('No orders yet.');
          return ContentWidth(
            maxWidth: 700,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              for (final o in orders)
                OrderTile(
                  order: o,
                  currency: currency,
                  trailing: (settings?.phone.isNotEmpty ?? false)
                      ? OutlinedButton.icon(
                          onPressed: () => openWhatsApp(settings!.phone,
                              'Hello, regarding my order ${o.id}'),
                          icon: const Icon(Icons.chat),
                          label: const Text('Chat about this order'),
                        )
                      : null,
                ),
            ]),
          );
        },
      ),
    );
  }
}
