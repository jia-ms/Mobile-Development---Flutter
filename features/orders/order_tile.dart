import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../models/store_order.dart';

class OrderTile extends StatelessWidget {
  const OrderTile(
      {super.key, required this.order, required this.currency, this.trailing});
  final StoreOrder order;
  final String currency;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
        child: ExpansionTile(
          title: Text('${money(order.total, currency)} · ${order.status.toUpperCase()}'),
          subtitle: Text(formatDateTime(order.createdAt)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final i in order.items)
              Text('• ${i.name} × ${i.qty}  (${money(i.price * i.qty, currency)})'),
            const SizedBox(height: 8),
            Text('${order.name} · ${order.phone}'),
            Text(order.address),
            if (order.notes.isNotEmpty) Text('Notes: ${order.notes}'),
            if (trailing != null) ...[const SizedBox(height: 8), trailing!],
          ],
        ),
      );
}
