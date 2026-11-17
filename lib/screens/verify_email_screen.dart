import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Verifica tu correo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_unread, size: 96),
                const SizedBox(height: 16),
                Text(
                  'Enviamos un correo de verificación a\n${auth.user?.email ?? ''}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Revisa también la carpeta de spam.',
                  textAlign: TextAlign.center,
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    auth.error!,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                if (auth.info != null) ...[
                  const SizedBox(height: 12),
                  Text(auth.info!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: auth.loading ? null : auth.reloadUser,
                  child: const Text('Ya verifiqué mi correo'),
                ),
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
          ),
        ),
      ),
    );
  }
}