import 'package:flutter/material.dart';

/// Trial payment modes. No real money moves — "card"/"upi" just simulate success.
enum PaymentMethod { cod, upi, card }

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.cod => 'Cash on Delivery',
    PaymentMethod.upi => 'UPI (demo)',
    PaymentMethod.card => 'Credit / Debit Card (demo)',
  };

  IconData get icon => switch (this) {
    PaymentMethod.cod => Icons.payments_outlined,
    PaymentMethod.upi => Icons.qr_code_2,
    PaymentMethod.card => Icons.credit_card,
  };
}

/// Drop into checkout_screen.dart below the address fields.
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment method', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final m in PaymentMethod.values)
          RadioListTile<PaymentMethod>(
            value: m,
            groupValue: value,
            onChanged: (v) => onChanged(v!),
            secondary: Icon(m.icon),
            title: Text(m.label),
            contentPadding: EdgeInsets.zero,
          ),
        const Text(
          'Trial mode: no real payment is taken.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

/// Fake processing step for UPI/Card so the flow feels real.
Future<void> simulatePayment(BuildContext context, PaymentMethod method) async {
  if (method == PaymentMethod.cod) return;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text('Processing payment…'),
        ],
      ),
    ),
  );
  await Future.delayed(const Duration(seconds: 2));
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
}