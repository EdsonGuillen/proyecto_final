import 'package:flutter/material.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, this.qty);
  double get subtotal => product.precio * qty;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get count => _items.values.fold(0, (s, i) => s + i.qty);
  double get total => _items.values.fold(0.0, (s, i) => s + i.subtotal);

  void add(Product p) {
    final existing = _items[p.id];
    if (existing != null) {
      existing.qty++;
    } else {
      _items[p.id] = CartItem(p, 1);
    }
    notifyListeners();
  }

  void decrease(Product p) {
    final existing = _items[p.id];
    if (existing == null) return;
    existing.qty--;
    if (existing.qty <= 0) _items.remove(p.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}