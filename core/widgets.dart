import 'package:flutter/material.dart';

import 'theme.dart';

class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 1100});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth), child: child),
  );
}

/// Horizontal padding that centres content to [maxWidth] inside slivers.
double sidePad(double width, {double maxWidth = 1100, double min = 16}) =>
    width > maxWidth + 2 * min ? (width - maxWidth) / 2 : min;

class ProductImage extends StatelessWidget {
  const ProductImage(this.url, {super.key, this.fit = BoxFit.cover});
  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFF222222),
      alignment: Alignment.center,
      child: const Icon(Icons.local_dining, color: AppColors.accent, size: 36),
    );
    if (url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      // Falls back to a plain <img> on web when the host has no CORS headers.
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (_, child, p) => p == null ? child : placeholder,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class QtyControl extends StatelessWidget {
  const QtyControl(
      {super.key, required this.qty, required this.onAdd, required this.onRemove});
  final int qty;
  final VoidCallback onAdd, onRemove;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onRemove,
        icon: const Icon(Icons.remove_circle_outline)),
    Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
    IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onAdd,
        icon: const Icon(Icons.add_circle_outline)),
  ]);
}

class CenteredMessage extends StatelessWidget {
  const CenteredMessage(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(padding: const EdgeInsets.all(24), child: Text(text)));
}

/// Standard Indian food label: green dot = veg, red dot = non-veg.
class VegMark extends StatelessWidget {
  const VegMark({super.key, required this.isVeg});
  final bool isVeg;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? Colors.green : Colors.red;
    return Container(
      width: 18,
      height: 18,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    );
  }
}