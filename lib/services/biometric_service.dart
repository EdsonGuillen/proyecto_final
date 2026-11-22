import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricResult { ok, failed, unavailable }

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Pide huella (o PIN del dispositivo si no hay huella registrada).
  /// unavailable = el equipo no tiene ningún método de seguridad configurado.
  static Future<BiometricResult> authenticate(String reason) async {
    if (kIsWeb) return BiometricResult.unavailable;
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return BiometricResult.unavailable;

      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return ok ? BiometricResult.ok : BiometricResult.failed;
    } catch (e) {
      debugPrint('BIOMETRIC ERROR: $e');
      return BiometricResult.failed;
    }
  }
}