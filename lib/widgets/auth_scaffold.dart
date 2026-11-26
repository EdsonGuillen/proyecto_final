import 'package:flutter/material.dart';

import 'brand_logo.dart';

/// Estructura visual común de login, registro, recuperación y verificación.
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? topRight;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.topRight,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 36),
              decoration: BoxDecoration(
                color: s.primary,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (canPop)
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: s.onPrimary),
                          onPressed: () => Navigator.maybePop(context),
                        )
                      else
                        const SizedBox(height: 48),
                      const Spacer(),
                      if (topRight != null) topRight!,
                    ],
                  ),
                  const BrandLogo(size: 84),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: s.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: s.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mensaje de error o información con el estilo de la app.
class AuthMessage extends StatelessWidget {
  final String text;
  final bool isError;

  const AuthMessage(this.text, {super.key, this.isError = true});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final bg = isError ? s.errorContainer : s.primaryContainer;
    final fg = isError ? s.onErrorContainer : s.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isError ? Icons.error_outline : Icons.info_outline,
              color: fg, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: fg))),
        ],
      ),
    );
  }
}