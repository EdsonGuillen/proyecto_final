// lib/main.dart
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/auth_gate.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://entwhrbqojimojwnnkfl.supabase.co',
    anonKey: 'sb_publishable_tn-RIWQswTPSOBnVXY4H4A_ZV1-Y9Wj',
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final theme = ThemeProvider();
  final onboarding = OnboardingProvider();
  final notifications = NotificationsProvider();
  await theme.load();
  await onboarding.load();
  unawaited(notifications.init());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: theme),
        ChangeNotifierProvider.value(value: onboarding),
        ChangeNotifierProvider.value(value: notifications),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    final seen = context.watch<OnboardingProvider>().seen;

    return MaterialApp(
      title: 'Proyecto Final',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: seen ? const AuthGate() : const OnboardingScreen(),
    );
  }
}