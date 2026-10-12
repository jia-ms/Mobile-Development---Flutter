import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/validators.dart';
import '../../core/widgets.dart';
import '../../data/order_repository.dart';
import '../../models/store_order.dart';
import '../../models/store_settings.dart';
import '../../state/auth_controller.dart';
import '../../state/cart_controller.dart';
import 'order_confirmation_screen.dart';
import 'payment_method_selector.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  late final _name =
  TextEditingController(text: context.read<AuthController>().profile?.name);
  late final _phone =
  TextEditingController(text: context.read<AuthController>().profile?.phone);
  final _address = TextEditingController();
  final _notes = TextEditingController();
  PaymentMethod _payment = PaymentMethod.cod;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _place() async {
    if (!_form.currentState!.validate()) return;
    final cart = context.read<CartController>();
    final uid = context.read<AuthController>().user!.uid;
    final repo = context.read<OrderRepository>();
    final router = GoRouter.of(context);
    final currency = context.read<StoreSettings?>()?.currency ?? '';
    final total = cart.total;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await simulatePayment(context, _payment);

      final orderId = await repo.placeOrder(
        userId: uid,
        items: cart.lines
            .map((l) => OrderItem(
            productId: l.product.id,
            name: l.product.displayName,
            price: l.product.price,
            qty: l.qty))
            .toList(),
        total: total,
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        notes: _notes.text.trim(),
        paymentMethod: _payment.name,
      );
      cart.clear();

      router.go(
        OrderConfirmationScreen.path,
        extra: OrderConfirmationArgs(
          orderId: orderId,
          total: total,
          currency: currency,
          paymentMethod: _payment,
        ),
      );
    } catch (e, st) {
      debugPrint('placeOrder failed: $e\n$st');
      if (mounted) {
        setState(() => _error = 'Could not place the order: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final currency = context.watch<StoreSettings?>()?.currency ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cart.isEmpty
          ? const CenteredMessage('Your cart is empty.')
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ContentWidth(
          maxWidth: 600,
          child: Form(
            key: _form,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Delivery details',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _name,
                    decoration:
                    const InputDecoration(labelText: 'Full name'),
                    validator: (v) => Validators.required(v, 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration:
                    const InputDecoration(labelText: 'Mobile number'),
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Delivery address'),
                    validator: (v) => Validators.required(v, 'Address'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    decoration: const InputDecoration(
                        labelText: 'Notes (optional)'),
                  ),
                  const SizedBox(height: 20),
                  PaymentMethodSelector(
                    value: _payment,
                    onChanged: (m) => setState(() => _payment = m),
                  ),
                  const SizedBox(height: 20),
                  Text(
                      '${cart.count} items · Total ${money(cart.total, currency)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_error!,
                          style: TextStyle(
                              color:
                              Theme.of(context).colorScheme.error)),
                    ),
                  FilledButton(
                    onPressed: _busy ? null : _place,
                    child: _busy
                        ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2))
                        : Text(_payment == PaymentMethod.cod
                        ? 'Place order'
                        : 'Pay ${money(cart.total, currency)} & place order'),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}