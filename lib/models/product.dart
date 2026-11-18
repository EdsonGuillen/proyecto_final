import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String imagenUrl;
  final String imagenPath;

  const Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.imagenUrl,
    required this.imagenPath,
  });

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Product(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      descripcion: d['descripcion'] ?? '',
      precio: (d['precio'] as num?)?.toDouble() ?? 0,
      categoria: d['categoria'] ?? '',
      imagenUrl: d['imagenUrl'] ?? '',
      imagenPath: d['imagenPath'] ?? '',
    );
  }
}