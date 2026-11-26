import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/form_fields_provider.dart';
import '../theme/app_inputs.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FormFieldsProvider(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    final f = context.watch<FormFieldsProvider>();
    final auth = context.watch<AuthProvider>();
    final s = Theme.of(context).colorScheme;

    return AuthScaffold(
      title: 'Crea tu cuenta',
      subtitle: 'Únete y descubre nuestros sabores artesanales',
      child: Form(
        key: f.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: f.name,
              decoration:
                  appInput(context, 'Nombre', icon: Icons.person_outline),
              validator: FormFieldsProvider.validateName,
            ),
            const SizedBox(height: 16),
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
                  : () async {
                      if (!f.validate()) return;
                      final ok = await auth.register(
                        f.name.text.trim(),
                        f.email.text.trim(),
                        f.password.text,
                      );
                      if (ok && context.mounted) Navigator.pop(context);
                    },
              child: auth.loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: s.onPrimary),
                    )
                  : const Text('Registrarme'),
            ),
          ],
        ),
      ),
    );
  }
}