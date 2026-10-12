import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets.dart';
import '../../data/order_repository.dart';
import '../../models/store_order.dart';
import '../../models/store_settings.dart';
import '../orders/order_tile.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});
  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  late final Stream<List<StoreOrder>> _stream =
      context.read<OrderRepository>().allOrders();

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<StoreSettings?>()?.currency ?? '';
    final repo = context.read<OrderRepository>();

    return StreamBuilder<List<StoreOrder>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) return const CenteredMessage('Could not load orders.');
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final orders = snap.data!;
        if (orders.isEmpty) return const CenteredMessage('No orders yet.');
        return ContentWidth(
          maxWidth: 800,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            for (final o in orders)
              OrderTile(
                order: o,
                currency: currency,
                trailing: Row(children: [
                  const Text('Status: '),
                  DropdownButton<String>(
                    value: orderStatuses.contains(o.status) ? o.status : null,
                    items: [
                      for (final s in orderStatuses)
                        DropdownMenuItem(value: s, child: Text(s)),
                    ],
                    onChanged: (v) {
                      if (v != null) repo.updateStatus(o.id, v);
                    },
                  ),
                ]),
              ),
          ]),
        );
      },
    );
  }
}
