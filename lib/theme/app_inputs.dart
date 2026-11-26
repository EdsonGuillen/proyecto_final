import 'package:flutter/material.dart';

InputDecoration appInput(
  BuildContext context,
  String label, {
  IconData? icon,
  Widget? suffix,
}) {
  final s = Theme.of(context).colorScheme;
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );

  return InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon) : null,
    suffixIcon: suffix,
    filled: true,
    fillColor: s.surfaceContainerLow,
    border: border(s.outlineVariant),
    enabledBorder: border(s.outlineVariant),
    focusedBorder: border(s.primary, 2),
    errorBorder: border(s.error),
    focusedErrorBorder: border(s.error, 2),
  );
}