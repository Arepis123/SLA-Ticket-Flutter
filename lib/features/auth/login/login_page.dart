import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/app_config.dart';
import '../../../data/repositories/auth_repository.dart';
import '../bloc/auth_bloc.dart';
import 'login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        repository: context.read<AuthRepository>(),
        onSignedIn: (session) =>
            context.read<AuthBloc>().add(AuthSignedIn(session)),
      ),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expired = context.select((AuthBloc bloc) => bloc.state.expired);
    final step = context.select((LoginCubit cubit) => cubit.state.step);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.monitor_heart_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SLA Monitor',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Live SLA status for administrators',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (expired && step == LoginStep.credentials) ...[
                    const _Banner('Your session ended. Please sign in again.'),
                    const SizedBox(height: 16),
                  ],
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: step == LoginStep.credentials
                        ? const _CredentialsForm()
                        : const _TwoFactorForm(),
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

class _CredentialsForm extends StatefulWidget {
  const _CredentialsForm();

  @override
  State<_CredentialsForm> createState() => _CredentialsFormState();
}

class _CredentialsFormState extends State<_CredentialsForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) return;
    context.read<LoginCubit>().submitCredentials(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginCubit>().state;
    final server = Uri.tryParse(context.read<AppConfig>().apiBaseUrl)?.host;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.error != null) ...[
            _Banner(state.error!),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _email,
            enabled: !state.submitting,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: state.fieldErrors['email'],
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            enabled: !state.submitting,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: state.fieldErrors['password'],
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.submitting ? null : _submit,
            child: state.submitting
                ? const _ButtonSpinner()
                : const Text('Sign in'),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('or'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: state.submitting
                ? null
                : () => context.read<LoginCubit>().startDemo(),
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Explore with demo data'),
          ),
          if (server != null && server.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Server: $server',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TwoFactorForm extends StatefulWidget {
  const _TwoFactorForm();

  @override
  State<_TwoFactorForm> createState() => _TwoFactorFormState();
}

class _TwoFactorFormState extends State<_TwoFactorForm> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    if (_code.text.trim().isEmpty) return;
    context.read<LoginCubit>().submitCode(_code.text);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    final state = context.watch<LoginCubit>().state;
    final recovery = state.useRecoveryCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Two-factor authentication',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          recovery
              ? 'Enter one of your emergency recovery codes. Each code works once.'
              : 'Enter the 6-digit code from your authenticator app.',
        ),
        const SizedBox(height: 16),
        if (state.error != null) ...[
          _Banner(state.error!),
          const SizedBox(height: 16),
        ],
        TextField(
          key: ValueKey(recovery),
          controller: _code,
          autofocus: true,
          enabled: !state.submitting,
          keyboardType: recovery ? TextInputType.text : TextInputType.number,
          autofillHints: recovery ? null : const [AutofillHints.oneTimeCode],
          inputFormatters: recovery
              ? null
              : [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
          autocorrect: false,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: recovery ? 'Recovery code' : 'Authentication code',
            errorText: state.fieldErrors[recovery ? 'recovery_code' : 'code'],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: state.submitting ? null : _submit,
          child: state.submitting
              ? const _ButtonSpinner()
              : const Text('Verify'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: state.submitting
              ? null
              : () {
                  _code.clear();
                  cubit.toggleRecoveryCode();
                },
          child: Text(
            recovery
                ? 'Use an authentication code instead'
                : 'Use a recovery code instead',
          ),
        ),
        TextButton(
          onPressed: state.submitting ? null : cubit.backToCredentials,
          child: const Text('Back'),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
