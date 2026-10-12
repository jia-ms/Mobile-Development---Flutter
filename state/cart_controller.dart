import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartLine {
  final Product product;
  int qty;
  CartLine(this.product, this.qty);
}

class CartController extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList();
  bool get isEmpty => _lines.isEmpty;
  int get count => _lines.values.fold(0, (a, l) => a + l.qty);
  num get total =>
      _lines.values.fold<num>(0, (a, l) => a + l.product.price * l.qty);

  int qtyOf(String productId) => _lines[productId]?.qty ?? 0;

  void add(Product p) {
    final line = _lines[p.id];
    if (line == null) {
      _lines[p.id] = CartLine(p, 1);
    } else {
      line.qty++;
    }
    notifyListeners();
  }

  void remove(Product p) {
    final line = _lines[p.id];
    if (line == null) return;
    line.qty--;
    if (line.qty <= 0) _lines.remove(p.id);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
