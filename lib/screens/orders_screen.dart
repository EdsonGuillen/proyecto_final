import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => OrdersProvider(c.read<AuthProvider>().user!.uid),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  String _date(DateTime? d) {
    if (d == null) return 'Procesando...';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OrdersProvider>();

    Widget body;
    if (o.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (o.error != null) {
      body = Center(child: Text(o.error!));
    } else if (o.orders.isEmpty) {
      body = const Center(child: Text('Aún no tienes pedidos.'));
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: o.orders.length,
        itemBuilder: (_, i) {
          final order = o.orders[i];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text('\$${order.total.toStringAsFixed(2)}  ·  ${order.estado}'),
              subtitle: Text('${_date(order.fecha)}\n${order.lineas.join('\n')}'),
              isThreeLine: true,
              trailing: order.simulado ? const Chip(label: Text('Simulado')) : null,
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: body,
        ),
      ),
    );
  }
}