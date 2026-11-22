import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';

/// Llave global para mostrar avisos en cualquier pantalla.
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Se ejecuta cuando llega un mensaje con la app en segundo plano o cerrada.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM segundo plano: ${message.messageId}');
}

enum NotifOrigin { foreground, background, terminated }

class AppNotification {
  final String title;
  final String body;
  final NotifOrigin origin;
  final DateTime time;

  const AppNotification({
    required this.title,
    required this.body,
    required this.origin,
    required this.time,
  });

  String get originLabel => switch (origin) {
        NotifOrigin.foreground => 'Primer plano',
        NotifOrigin.background => 'Segundo plano',
        NotifOrigin.terminated => 'App cerrada',
      };
}

class NotificationsProvider extends ChangeNotifier {
  static const topics = ['ofertas', 'novedades', 'avisos'];

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final List<AppNotification> items = [];
  final Set<String> subscribed = {};
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;

  String? token;
  bool permissionGranted = false;
  String? error;

  Future<void> init() async {
    // Listeners globales: se registran una sola vez y viven toda la app.
    _onMessageSub = FirebaseMessaging.onMessage.listen(_onForeground);
    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(
      (m) => _add(m, NotifOrigin.background),
    );

    try {
      final settings = await _fcm.requestPermission();
      permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      final prefs = await SharedPreferences.getInstance();
      subscribed.addAll(prefs.getStringList('fcm_topics') ?? []);

      token = await _fcm.getToken();

      // Mensaje que abrió la app estando cerrada (terminated).
      final initial = await _fcm.getInitialMessage();
      if (initial != null) _add(initial, NotifOrigin.terminated);
    } catch (e) {
      debugPrint('FCM INIT ERROR: $e');
      error = 'No se pudieron inicializar las notificaciones';
    }
    notifyListeners();
  }

  void _add(RemoteMessage m, NotifOrigin origin) {
    items.insert(
      0,
      AppNotification(
        title: m.notification?.title ?? m.data['title'] ?? 'Notificación',
        body: m.notification?.body ?? m.data['body'] ?? '',
        origin: origin,
        time: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void _onForeground(RemoteMessage m) {
    _add(m, NotifOrigin.foreground);
    final n = items.first;
    messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (n.body.isNotEmpty) Text(n.body),
            ],
          ),
        ),
      );
  }

  Future<void> toggleTopic(String topic) async {
    error = null;
    try {
      if (subscribed.contains(topic)) {
        await _fcm.unsubscribeFromTopic(topic);
        subscribed.remove(topic);
      } else {
        await _fcm.subscribeToTopic(topic);
        subscribed.add(topic);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('fcm_topics', subscribed.toList());
    } catch (e) {
      debugPrint('TOPIC ERROR: $e');
      error = 'No se pudo cambiar la suscripción. Revisa tu conexión.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _onMessageSub?.cancel();
    _onOpenedSub?.cancel();
    super.dispose();
  }
}