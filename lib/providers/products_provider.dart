import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, FileOptions;

import '../models/product.dart';

class ProductsProvider extends ChangeNotifier {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('productos');
  final _bucket = Supabase.instance.client.storage.from('productos');
  late final StreamSubscription _sub;

  List<Product> products = [];
  bool loading = true;
  bool saving = false;
  String? error;
  String? saveError;

  ProductsProvider() {
    _sub = _col.orderBy('creadoEn', descending: true).snapshots().listen(
      (snap) {
        products = snap.docs.map(Product.fromDoc).toList();
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('FIRESTORE ERROR: $e');
        error = 'No se pudieron cargar los productos';
        loading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> save({
    Product? existing,
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
    Uint8List? imageBytes,
  }) async {
    saving = true;
    saveError = null;
    notifyListeners();
    try {
      var url = existing?.imagenUrl ?? '';
      var path = existing?.imagenPath ?? '';

      if (imageBytes != null) {
        final newPath = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _bucket.uploadBinary(
          newPath,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        final oldPath = path;
        url = _bucket.getPublicUrl(newPath);
        path = newPath;
        if (oldPath.isNotEmpty) {
          try {
            await _bucket.remove([oldPath]);
          } catch (_) {}
        }
      }

      final data = {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'categoria': categoria,
        'imagenUrl': url,
        'imagenPath': path,
      };

      if (existing == null) {
        await _col.add({...data, 'creadoEn': FieldValue.serverTimestamp()});
      } else {
        await _col.doc(existing.id).update(data);
      }
      return true;
    } catch (e) {
      debugPrint('SAVE ERROR: $e');
      saveError = 'No se pudo guardar el producto. Revisa tu conexión.';
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> delete(Product p) async {
    try {
      await _col.doc(p.id).delete();
      if (p.imagenPath.isNotEmpty) {
        await _bucket.remove([p.imagenPath]);
      }
    } catch (e) {
      debugPrint('DELETE ERROR: $e');
      error = 'No se pudo eliminar el producto';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}