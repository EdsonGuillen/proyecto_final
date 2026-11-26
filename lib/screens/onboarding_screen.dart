import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';
import '../widgets/brand_logo.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const _pages = [
    (
      Icons.bakery_dining,
      'Sabor hecho a mano',
      'Galletas, salsas, postres y dulces típicos elaborados de forma artesanal.',
    ),
    (
      Icons.shopping_basket,
      'Pide fácil y seguro',
      'Arma tu carrito, paga con tarjeta y consulta tus pedidos cuando quieras.',
    ),
    (
      Icons.notifications_active,
      'Entérate de lo nuevo',
      'Activa las notificaciones y recibe ofertas y novedades de temporada.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OnboardingProvider>();
    final s = Theme.of(context).colorScheme;
    final isLast = prov.page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BrandLogo(
                    size: 36,
                    background: s.primary,
                    foreground: s.onPrimary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Productos artesanales Gema',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: s.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: prov.controller,
                onPageChanged: prov.onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final (icon, title, text) = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Illustration(icon: icon),
                        const SizedBox(height: 40),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: s.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: s.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  width: prov.page == i ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: prov.page == i ? s.primary : s.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLast ? prov.finish : prov.next,
                  child: Text(isLast ? 'Comenzar' : 'Siguiente'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final IconData icon;
  const _Illustration({required this.icon});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: s.primaryContainer,
            ),
          ),
          Positioned(
            top: 8,
            right: 16,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.tertiary.withValues(alpha: 0.85),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 10,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
          Icon(icon, size: 110, color: s.primary),
        ],
      ),
    );
  }
}