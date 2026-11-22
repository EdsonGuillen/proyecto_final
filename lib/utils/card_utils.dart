import 'package:flutter/services.dart';

class CardUtils {
  static String digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  static bool luhn(String number) {
    final d = digits(number);
    var sum = 0;
    var alt = false;
    for (var i = d.length - 1; i >= 0; i--) {
      var n = int.parse(d[i]);
      if (alt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alt = !alt;
    }
    return d.isNotEmpty && sum % 10 == 0;
  }

  static String brand(String number) {
    final d = digits(number);
    if (d.startsWith('4')) return 'Visa';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(d)) return 'Mastercard';
    if (RegExp(r'^3[47]').hasMatch(d)) return 'Amex';
    return '';
  }

  static String? validateHolder(String? v) =>
      (v == null || v.trim().length < 3) ? 'Ingresa el nombre del titular' : null;

  static String? validateNumber(String? v) {
    final d = digits(v ?? '');
    if (d.length < 15 || d.length > 16) return 'Número incompleto';
    if (!luhn(d)) return 'Número de tarjeta inválido';
    return null;
  }

  static String? validateExpiry(String? v) {
    final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(v ?? '');
    if (m == null) return 'Formato MM/AA';
    final month = int.parse(m.group(1)!);
    final year = 2000 + int.parse(m.group(2)!);
    if (month < 1 || month > 12) return 'Mes inválido';
    final endOfMonth = DateTime(year, month + 1, 1);
    if (!endOfMonth.isAfter(DateTime.now())) return 'Tarjeta vencida';
    return null;
  }

  static String? validateCvv(String? v) {
    final d = digits(v ?? '');
    return (d.length < 3 || d.length > 4) ? 'CVV inválido' : null;
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var d = CardUtils.digits(newValue.text);
    if (d.length > 16) d = d.substring(0, 16);
    final buf = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(d[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var d = CardUtils.digits(newValue.text);
    if (d.length > 4) d = d.substring(0, 4);
    final text = d.length >= 3 ? '${d.substring(0, 2)}/${d.substring(2)}' : d;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}