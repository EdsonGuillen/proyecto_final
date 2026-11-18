import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/user_avatar.dart';
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

  // La ruta nueva queda fuera del árbol de este provider,
  // por eso se le pasa de forma explícita con .value
  void _openForm(BuildContext context, {Product? product}) {
    final prods = context.read<ProductsProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: prods,
          child: ProductFormScreen(product: product),
        ),
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
      context.read<ProductsProvider>().delete(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;
    final prods = context.watch<ProductsProvider>();

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
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
          IconButton(
            icon: const UserAvatar(radius: 14),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: auth.logout,
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