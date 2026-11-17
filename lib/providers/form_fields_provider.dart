import 'package:flutter/material.dart';

class FormFieldsProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  void toggleObscure() {
    obscure = !obscure;
    notifyListeners();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  static String? validateEmail(String? v) {
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '');
    return ok ? null : 'Ingresa un correo válido';
  }

  static String? validatePassword(String? v) =>
      (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null;

  static String? validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }
}