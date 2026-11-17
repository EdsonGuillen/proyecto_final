import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _providerName(AuthProvider auth) {
    final id = auth.user?.providerData.isNotEmpty ?? false
        ? auth.user!.providerData.first.providerId
        : '';
    switch (id) {
      case 'google.com':
        return 'Google';
      case 'github.com':
        return 'GitHub';
      case 'password':
        return 'Correo y contraseña';
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const UserAvatar(radius: 56),
                const SizedBox(height: 12),
                if (auth.isPasswordUser)
                  OutlinedButton.icon(
                    onPressed: auth.loading ? null : auth.changePhoto,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Cambiar foto'),
                  ),
                if (auth.loading) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                ],
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    auth.error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user?.displayName ?? 'Sin nombre'),
                  subtitle: const Text('Nombre'),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(user?.email ?? 'Sin correo'),
                  subtitle: const Text('Correo'),
                ),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: Text(_providerName(auth)),
                  subtitle: const Text('Método de acceso'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}