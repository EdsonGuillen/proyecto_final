import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../services/payment_service.dart';
import '../utils/card_utils.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutProvider(),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CheckoutProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pago')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: c.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(PaymentService.modeLabel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text(
                            'Tarjetas de prueba: 4242 4242 4242 4242 (aprobada), '
                            '4000 0000 0000 0002 (rechazada) y '
                            '4000 0000 0000 9995 (fondos insuficientes). '
                            'Usa cualquier fecha futura y cualquier CVV. '
                            'No uses una tarjeta real.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: c.holder,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Titular de la tarjeta',
                      border: OutlineInputBorder(),
                    ),
                    validator: CardUtils.validateHolder,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: c.number,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CardNumberFormatter()],
                    decoration: InputDecoration(
                      labelText: 'Número de tarjeta',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.credit_card),
                      suffixText: c.brand,
                    ),
                    validator: CardUtils.validateNumber,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: c.expiry,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ExpiryFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Vence (MM/AA)',
                            border: OutlineInputBorder(),
                          ),
                          validator: CardUtils.validateExpiry,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: c.cvv,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                          ),
                          validator: CardUtils.validateCvv,
                        ),
                      ),
                    ],
                  ),
                  if (c.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      c.error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: c.paying || cart.isEmpty
                        ? null
                        : () async {
                            final uid =
                                context.read<AuthProvider>().user!.uid;
                            final ok = await c.pay(
                              items: cart.items,
                              total: cart.total,
                              uid: uid,
                            );
                            if (!ok || !context.mounted) return;

                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => AlertDialog(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green, size: 48),
                                title: const Text('Pago aprobado'),
                                content: Text(
                                  'Pedido: ${c.lastOrderId}\n'
                                  'Pago: ${c.lastPaymentId}\n'
                                  '${c.lastSimulated ? 'Modo simulado' : 'Stripe (modo de prueba)'}',
                                ),
                                actions: [
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                            if (!context.mounted) return;
                            context.read<CartProvider>().clear();
                            Navigator.popUntil(context, (r) => r.isFirst);
                          },
                    child: c.paying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Pagar \$${cart.total.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}