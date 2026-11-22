import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<NotificationsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(
              n.permissionGranted
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            title: Text(n.permissionGranted
                ? 'Permiso concedido'
                : 'Permiso de notificaciones denegado'),
          ),
          if (n.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                n.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const Divider(),
          Text('Canales (topics)',
              style: Theme.of(context).textTheme.titleMedium),
          for (final t in NotificationsProvider.topics)
            SwitchListTile(
              title: Text(t),
              value: n.subscribed.contains(t),
              onChanged: (_) => context.read<NotificationsProvider>().toggleTopic(t),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Token de este dispositivo'),
            subtitle: Text(
              n.token ?? 'No disponible',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: n.token == null
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: n.token!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token copiado')),
                      );
                    },
            ),
          ),
          const Divider(),
          Text('Recibidas', style: Theme.of(context).textTheme.titleMedium),
          if (n.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aún no has recibido notificaciones.'),
            ),
          for (final item in n.items)
            Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.body),
                trailing: Chip(label: Text(item.originLabel)),
              ),
            ),
        ],
      ),
    );
  }
}