import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../providers/theme_provider.dart';
import '../services/biometric_service.dart';
import '../widgets/product_card.dart';
import '../widgets/user_avatar.dart';
import 'cart_screen.dart';
import 'map_screen.dart';
import 'notifications_screen.dart';
import 'orders_screen.dart';
import 'product_form_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductsProvider(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // La ruta nueva queda fuera del árbol de este provider,
  // por eso se le pasa de forma explícita con .value
  void _openForm(BuildContext context, {Product? product}) {
    final prods = context.read<ProductsProvider>();
    _push(
      context,
      ChangeNotifierProvider.value(
        value: prods,
        child: ProductFormScreen(product: product),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${p.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final result = await BiometricService.authenticate(
        'Confirma con tu huella para eliminar "${p.nombre}"',
      );
      if (!context.mounted) return;
      if (result == BiometricResult.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticación cancelada o fallida')),
        );
        return;
      }
      context.read<ProductsProvider>().delete(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final prods = context.watch<ProductsProvider>();
    final cart = context.watch<CartProvider>();

    Widget body;
    if (prods.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (prods.error != null) {
      body = Center(child: Text(prods.error!));
    } else if (prods.products.isEmpty) {
      body = const Center(child: Text('Aún no hay productos. Agrega el primero.'));
    } else {
      body = GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: prods.products.length,
        itemBuilder: (_, i) {
          final p = prods.products[i];
          return ProductCard(
            product: p,
            onEdit: () => _openForm(context, product: p),
            onDelete: () => _confirmDelete(context, p),
            onAdd: () {
              context.read<CartProvider>().add(p);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('"${p.nombre}" agregado al carrito'),
                    duration: const Duration(seconds: 1),
                  ),
                );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            tooltip: 'Carrito',
            icon: Badge.count(
              count: cart.count,
              isLabelVisible: cart.count > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () => _push(context, const CartScreen()),
          ),
          IconButton(
            tooltip: 'Perfil',
            icon: const UserAvatar(radius: 14),
            onPressed: () => _push(context, const ProfileScreen()),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'orders':
                  _push(context, const OrdersScreen());
                  break;
                case 'notifs':
                  _push(context, const NotificationsScreen());
                  break;
                case 'map':
                  _push(context, const MapScreen());
                  break;
                case 'theme':
                  context.read<ThemeProvider>().toggle();
                  break;
                case 'logout':
                  context.read<CartProvider>().clear();
                  context.read<AuthProvider>().logout();
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'orders', child: Text('Mis pedidos')),
              const PopupMenuItem(value: 'notifs', child: Text('Notificaciones')),
              const PopupMenuItem(value: 'map', child: Text('Ubicación')),
              PopupMenuItem(
                value: 'theme',
                child: Text(isDark ? 'Modo claro' : 'Modo oscuro'),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
      ),
    );
  }
}