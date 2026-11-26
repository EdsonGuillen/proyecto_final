import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/form_fields_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_inputs.dart';
import '../widgets/auth_scaffold.dart';
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
    final s = Theme.of(context).colorScheme;

    return AuthScaffold(
      title: 'Bienvenido a Gema',
      subtitle: 'Productos artesanales hechos con cariño',
      topRight: IconButton(
        tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
            color: s.onPrimary),
        onPressed: () => context.read<ThemeProvider>().toggle(),
      ),
      child: Form(
        key: f.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: f.email,
              keyboardType: TextInputType.emailAddress,
              decoration:
                  appInput(context, 'Correo', icon: Icons.email_outlined),
              validator: FormFieldsProvider.validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: f.password,
              obscureText: f.obscure,
              decoration: appInput(
                context,
                'Contraseña',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                      f.obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: f.toggleObscure,
                ),
              ),
              validator: FormFieldsProvider.validatePassword,
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              AuthMessage(auth.error!),
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
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: s.onPrimary),
                    )
                  : const Text('Entrar'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
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
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'o continúa con',
                    style: TextStyle(color: s.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: auth.loading ? null : auth.signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Google'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: auth.loading ? null : auth.signInWithGithub,
              icon: const Icon(Icons.code),
              label: const Text('GitHub'),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('¿Aún no tienes cuenta?',
                    style: TextStyle(color: s.onSurface.withValues(alpha: 0.7))),
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
          ],
        ),
      ),
    );
  }
}