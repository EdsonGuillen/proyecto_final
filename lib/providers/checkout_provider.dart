import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import '../services/payment_service.dart';
import '../utils/card_utils.dart';
import 'cart_provider.dart';

class CheckoutProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final holder = TextEditingController();
  final number = TextEditingController();
  final expiry = TextEditingController();
  final cvv = TextEditingController();

  bool paying = false;
  String? error;
  String? lastOrderId;
  String? lastPaymentId;
  bool lastSimulated = false;

  CheckoutProvider() {
    number.addListener(notifyListeners);
  }

  String get brand => CardUtils.brand(number.text);

  Future<bool> pay({
    required List<CartItem> items,
    required double total,
    required String uid,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    error = null;
    notifyListeners();

    final bio = await BiometricService.authenticate(
      'Confirma el pago de \$${total.toStringAsFixed(2)} con tu huella',
    );
    if (bio == BiometricResult.failed) {
      error = 'No se pudo confirmar tu identidad. El pago no se realizó.';
      notifyListeners();
      return false;
    }

    paying = true;
    notifyListeners();

    final result = await PaymentService.charge(
      amount: total,
      cardNumber: number.text,
      description: 'Pedido de ${items.length} producto(s)',
    );

    if (!result.success) {
      paying = false;
      error = result.message;
      notifyListeners();
      return false;
    }

    // No se espera la escritura: Firestore la guarda localmente y sincroniza
    // sola, así la pantalla no se queda cargando si se pierde la conexión.
    final ref = FirebaseFirestore.instance.collection('pedidos').doc();
    unawaited(ref.set({
      'uid': uid,
      'items': items
          .map((i) => {
                'id': i.product.id,
                'nombre': i.product.nombre,
                'precio': i.product.precio,
                'cantidad': i.qty,
              })
          .toList(),
      'total': total,
      'estado': 'pagado',
      'paymentId': result.paymentId,
      'simulado': result.simulated,
      'creadoEn': FieldValue.serverTimestamp(),
    }).then((_) {}, onError: (e) => debugPrint('ORDER ERROR: $e')));

    lastOrderId = ref.id;
    lastPaymentId = result.paymentId;
    lastSimulated = result.simulated;
    paying = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    number.removeListener(notifyListeners);
    holder.dispose();
    number.dispose();
    expiry.dispose();
    cvv.dispose();
    super.dispose();
  }
}