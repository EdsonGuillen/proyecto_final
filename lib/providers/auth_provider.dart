import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, FileOptions;

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _sub;

  User? user;
  bool loading = false;
  String? error;
  String? info;

  AuthProvider() {
    user = _auth.currentUser;
    _sub = _auth.userChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  bool get isPasswordUser =>
      user?.providerData.any((p) => p.providerId == 'password') ?? false;

  bool get needsVerification =>
      user != null && isPasswordUser && !user!.emailVerified;

  void clearMessages() {
    error = null;
    info = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    info = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('AUTH ERROR: ${e.code} - ${e.message}');
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        error = 'Inicio de sesión interrumpido (${e.code}). Intenta de nuevo.';
      } else {
        error = '${_message(e.code)}\n[${e.code}] ${e.message ?? ''}';
      }
      return false;
    } catch (e) {
      debugPrint('AUTH ERROR (otro): $e');
      error = 'Ocurrió un error inesperado\n$e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) => _run(() async {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      });

  Future<bool> register(String name, String email, String password) =>
      _run(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await cred.user!.updateDisplayName(name);
        await cred.user!.sendEmailVerification();
        await cred.user!.reload();
        user = _auth.currentUser;
      });

  Future<bool> resendVerification() => _run(() async {
        await _auth.currentUser!.sendEmailVerification();
        info = 'Correo de verificación reenviado';
      });

  Future<bool> reloadUser() => _run(() async {
        await _auth.currentUser!.reload();
        user = _auth.currentUser;
        if (!user!.emailVerified) {
          info = 'Aún no has verificado tu correo';
        }
      });

  Future<bool> sendPasswordReset(String email) => _run(() async {
        await _auth.sendPasswordResetEmail(email: email);
        info = 'Te enviamos un correo para restablecer tu contraseña';
      });

  Future<void> logout() => _auth.signOut();

  Future<bool> signInWithGoogle() => _run(() async {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        await _auth.signInWithProvider(provider);
      });

  Future<bool> signInWithGithub() => _run(() async {
        final provider = GithubAuthProvider()..addScope('user:email');
        await _auth.signInWithProvider(provider);
      });

  Future<bool> changePhoto() => _run(() async {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          imageQuality: 80,
        );
        if (picked == null) return;

        final bytes = await picked.readAsBytes();
        final path = '${user!.uid}.jpg';
        final bucket = Supabase.instance.client.storage.from('avatars');

        await bucket.uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

        final url =
            '${bucket.getPublicUrl(path)}?t=${DateTime.now().millisecondsSinceEpoch}';

        await user!.updatePhotoURL(url);
        await user!.reload();
        user = _auth.currentUser;
      });

  String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo no es válido';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'too-many-requests':
        return 'Demasiados intentos, espera un momento';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con ese correo usando otro método';
      default:
        return 'Error de autenticación';
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}