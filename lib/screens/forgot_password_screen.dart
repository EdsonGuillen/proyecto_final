import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/form_fields_provider.dart';
import '../theme/app_inputs.dart';
import '../widgets/auth_scaffold.dart';

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

    return AuthScaffold(
      title: 'Recupera tu contraseña',
      subtitle: 'Te enviaremos un enlace a tu correo para restablecerla',
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
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              AuthMessage(auth.error!),
            ],
            if (auth.info != null) ...[
              const SizedBox(height: 12),
              AuthMessage(auth.info!, isError: false),
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
    );
  }
}