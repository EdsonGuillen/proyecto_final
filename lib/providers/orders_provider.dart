import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderSummary {
  final String id;
  final double total;
  final DateTime? fecha;
  final String estado;
  final bool simulado;
  final List<String> lineas;

  const OrderSummary({
    required this.id,
    required this.total,
    required this.fecha,
    required this.estado,
    required this.simulado,
    required this.lineas,
  });
}

class OrdersProvider extends ChangeNotifier {
  late final StreamSubscription _sub;
  List<OrderSummary> orders = [];
  bool loading = true;
  String? error;

  OrdersProvider(String uid) {
    _sub = FirebaseFirestore.instance
        .collection('pedidos')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen(
      (snap) {
        orders = snap.docs.map(_fromDoc).toList()
          ..sort((a, b) {
            final da = a.fecha ?? DateTime.now();
            final db = b.fecha ?? DateTime.now();
            return db.compareTo(da);
          });
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('ORDERS ERROR: $e');
        error = 'No se pudieron cargar tus pedidos';
        loading = false;
        notifyListeners();
      },
    );
  }

  OrderSummary _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final items = (d['items'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return OrderSummary(
      id: doc.id,
      total: (d['total'] as num?)?.toDouble() ?? 0,
      fecha: (d['creadoEn'] as Timestamp?)?.toDate(),
      estado: d['estado'] ?? '',
      simulado: d['simulado'] ?? false,
      lineas: items.map((i) => '${i['cantidad']} × ${i['nombre']}').toList(),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}