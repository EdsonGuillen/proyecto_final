import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/card_utils.dart';

class PaymentResult {
  final bool success;
  final String message;
  final String? paymentId;
  final bool simulated;

  const PaymentResult._(this.success, this.message, this.paymentId, this.simulated);

  factory PaymentResult.ok(String id, {required bool simulated}) =>
      PaymentResult._(true, 'Pago aprobado', id, simulated);

  factory PaymentResult.fail(String message, {bool simulated = false}) =>
      PaymentResult._(false, message, null, simulated);
}

class PaymentService {
  static const String _secret = String.fromEnvironment('STRIPE_SECRET_KEY');
  static const String currency = 'mxn';

  /// Solo se usa Stripe si la clave es de PRUEBA.
  static bool get usesStripe => _secret.startsWith('sk_test_');

  static String get modeLabel =>
      usesStripe ? 'Stripe (modo de prueba)' : 'Modo simulado (sin clave de Stripe)';

  /// Tarjetas de prueba -> método de pago de prueba de Stripe.
  static String? _testPaymentMethod(String digits) {
    switch (digits) {
      case '4242424242424242':
        return 'pm_card_visa';
      case '5555555555554444':
        return 'pm_card_mastercard';
      case '4000000000000002':
        return 'pm_card_chargeDeclined';
      case '4000000000009995':
        return 'pm_card_chargeDeclinedInsufficientFunds';
      default:
        return null;
    }
  }

  static Future<PaymentResult> charge({
    required double amount,
    required String cardNumber,
    required String description,
  }) async {
    final pm = _testPaymentMethod(CardUtils.digits(cardNumber));
    if (pm == null) {
      return PaymentResult.fail(
        'Usa una tarjeta de prueba, por ejemplo 4242 4242 4242 4242.',
        simulated: !usesStripe,
      );
    }
    final cents = (amount * 100).round();
    if (!usesStripe) return _simulate(pm);

    try {
      final res = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {'Authorization': 'Bearer $_secret'},
        body: {
          'amount': '$cents',
          'currency': currency,
          'payment_method': pm,
          'confirm': 'true',
          'automatic_payment_methods[enabled]': 'true',
          'automatic_payment_methods[allow_redirects]': 'never',
          'description': description,
        },
      ).timeout(const Duration(seconds: 20));

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && json['status'] == 'succeeded') {
        return PaymentResult.ok(json['id'] as String, simulated: false);
      }
      final err = (json['error'] as Map<String, dynamic>?) ?? {};
      final code = (err['decline_code'] ?? err['code'] ?? '').toString();
      if (code == 'insufficient_funds') {
        return PaymentResult.fail('Fondos insuficientes.');
      }
      if (code == 'card_declined' || code == 'generic_decline') {
        return PaymentResult.fail('Tarjeta rechazada.');
      }
      debugPrint('STRIPE ERROR: ${res.body}');
      return PaymentResult.fail(
          (err['message'] as String?) ?? 'No se pudo procesar el pago.');
    } catch (e) {
      debugPrint('PAYMENT ERROR: $e');
      return PaymentResult.fail(
          'No se pudo contactar al servicio de pagos. Revisa tu conexión.');
    }
  }

  static Future<PaymentResult> _simulate(String pm) async {
    await Future.delayed(const Duration(seconds: 1));
    if (pm == 'pm_card_chargeDeclined') {
      return PaymentResult.fail('Tarjeta rechazada.', simulated: true);
    }
    if (pm == 'pm_card_chargeDeclinedInsufficientFunds') {
      return PaymentResult.fail('Fondos insuficientes.', simulated: true);
    }
    return PaymentResult.ok('sim_${DateTime.now().millisecondsSinceEpoch}',
        simulated: true);
  }
}