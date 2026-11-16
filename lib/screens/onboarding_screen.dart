import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const _pages = [
    (Icons.waving_hand, 'Bienvenido', 'Conoce lo que puedes hacer en la app.'),
    (Icons.cloud_sync, 'Todo en la nube', 'Tus datos se sincronizan en tiempo real.'),
    (Icons.notifications_active, 'Mantente al día', 'Recibe notificaciones de lo que te interesa.'),
  ];

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OnboardingProvider>();
    final isLast = prov.page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: prov.controller,
                onPageChanged: prov.onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final (icon, title, text) = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 120),
                        const SizedBox(height: 32),
                        Text(title, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 12),
                        Text(text, textAlign: TextAlign.center),
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
                  width: prov.page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: prov.page == i
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: isLast ? prov.finish : prov.next,
                child: Text(isLast ? 'Comenzar' : 'Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}