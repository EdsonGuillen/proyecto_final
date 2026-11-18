import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';

class ProductFormProvider extends ChangeNotifier {
  final Product? existing;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nombre;
  late final TextEditingController descripcion;
  late final TextEditingController precio;
  late final TextEditingController categoria;
  Uint8List? imageBytes;

  ProductFormProvider(this.existing) {
    nombre = TextEditingController(text: existing?.nombre ?? '');
    descripcion = TextEditingController(text: existing?.descripcion ?? '');
    precio = TextEditingController(
        text: existing != null ? existing!.precio.toString() : '');
    categoria = TextEditingController(text: existing?.categoria ?? '');
  }

  double get precioValue =>
      double.tryParse(precio.text.replaceAll(',', '.')) ?? 0;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (picked == null) return;
    imageBytes = await picked.readAsBytes();
    notifyListeners();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  static String? validateNombre(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null;

  static String? validatePrecio(String? v) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    return (n == null || n <= 0) ? 'Ingresa un precio válido' : null;
  }

  @override
  void dispose() {
    nombre.dispose();
    descripcion.dispose();
    precio.dispose();
    categoria.dispose();
    super.dispose();
  }
}