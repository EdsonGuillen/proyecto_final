import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/form_fields_provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FormFieldsProvider(),
      child: const _ForgotView(),
    );
  }
}

class _ForgotView extends StatelessWidget {
  const _ForgotView();

  @override
  Widget build(BuildContext context) {
    final f = context.watch<FormFieldsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
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
                  const Text(
                    'Escribe tu correo y te enviaremos un enlace para '
                    'restablecer tu contraseña.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: f.email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormFieldsProvider.validateEmail,
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      auth.error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  if (auth.info != null) ...[
                    const SizedBox(height: 12),
                    Text(auth.info!),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: auth.loading
                        ? null
                        : () {
                            if (f.validate()) {
                              auth.sendPasswordReset(f.email.text.trim());
                            }
                          },
                    child: const Text('Enviar enlace'),
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