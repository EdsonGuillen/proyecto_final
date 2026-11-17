import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/form_fields_provider.dart';
import '../providers/theme_provider.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FormFieldsProvider(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final f = context.watch<FormFieldsProvider>();
    final auth = context.watch<AuthProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: f.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: f.email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormFieldsProvider.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: f.password,
                    obscureText: f.obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(f.obscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: f.toggleObscure,
                      ),
                    ),
                    validator: FormFieldsProvider.validatePassword,
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      auth.error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: auth.loading
                        ? null
                        : () {
                            if (f.validate()) {
                              auth.login(f.email.text.trim(), f.password.text);
                            }
                          },
                    child: auth.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                  TextButton(
                    onPressed: () {
                      auth.clearMessages();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                  const SizedBox(height: 8),
const Row(
  children: [
    Expanded(child: Divider()),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('o continúa con'),
    ),
    Expanded(child: Divider()),
  ],
),
const SizedBox(height: 12),
OutlinedButton.icon(
  onPressed: auth.loading ? null : auth.signInWithGoogle,
  icon: const Icon(Icons.g_mobiledata, size: 28),
  label: const Text('Google'),
),
const SizedBox(height: 8),
OutlinedButton.icon(
  onPressed: auth.loading ? null : auth.signInWithGithub,
  icon: const Icon(Icons.code),
  label: const Text('GitHub'),
),
                  TextButton(
                    onPressed: () {
                      auth.clearMessages();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Crear cuenta'), 
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}