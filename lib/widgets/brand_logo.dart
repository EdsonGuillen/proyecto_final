import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final Color? background;
  final Color? foreground;

  const BrandLogo({
    super.key,
    this.size = 84,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final fg = foreground ?? s.onPrimary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background ?? fg.withValues(alpha: 0.18),
        border: Border.all(color: fg.withValues(alpha: 0.5), width: 2),
      ),
      child: Icon(Icons.bakery_dining, size: size * 0.55, color: fg),
    );
  }
}