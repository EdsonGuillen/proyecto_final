import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final s = Theme.of(context).colorScheme;

    return AuthScaffold(
      title: 'Verifica tu correo',
      subtitle: 'Enviamos un enlace de confirmación a\n${auth.user?.email ?? ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Abre el enlace del correo y luego regresa aquí. '
            'Revisa también la carpeta de spam.',
            textAlign: TextAlign.center,
            style: TextStyle(color: s.onSurface.withValues(alpha: 0.75)),
          ),
          if (auth.error != null) ...[
            const SizedBox(height: 12),
            AuthMessage(auth.error!),
          ],
          if (auth.info != null) ...[
            const SizedBox(height: 12),
            AuthMessage(auth.info!, isError: false),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: auth.loading ? null : auth.reloadUser,
            child: const Text('Ya verifiqué mi correo'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: auth.loading ? null : auth.resendVerification,
            child: const Text('Reenviar correo'),
          ),
          TextButton(
            onPressed: auth.logout,
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}