import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_form_provider.dart';
import '../providers/products_provider.dart';

class ProductFormScreen extends StatelessWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(product),
      child: _FormView(product: product),
    );
  }
}

class _FormView extends StatelessWidget {
  final Product? product;
  const _FormView({required this.product});

  Widget _preview(ProductFormProvider f) {
    if (f.imageBytes != null) {
      return Image.memory(f.imageBytes!, fit: BoxFit.cover);
    }
    final url = product?.imagenUrl ?? '';
    if (url.isNotEmpty) {
      return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey.withValues(alpha: 0.2),
      child: const Icon(Icons.add_photo_alternate, size: 64),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = context.watch<ProductFormProvider>();
    final prods = context.watch<ProductsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(product == null ? 'Nuevo producto' : 'Editar producto'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: f.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: prods.saving ? null : f.pickImage,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _preview(f),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: prods.saving ? null : f.pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Elegir imagen'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: f.nombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: ProductFormProvider.validateNombre,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: f.descripcion,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: f.precio,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: ProductFormProvider.validatePrecio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: f.categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (prods.saveError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      prods.saveError!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: prods.saving
                        ? null
                        : () async {
                            if (!f.validate()) return;
                            final ok = await prods.save(
                              existing: product,
                              nombre: f.nombre.text.trim(),
                              descripcion: f.descripcion.text.trim(),
                              precio: f.precioValue,
                              categoria: f.categoria.text.trim(),
                              imageBytes: f.imageBytes,
                            );
                            if (ok && context.mounted) Navigator.pop(context);
                          },
                    child: prods.saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar'),
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