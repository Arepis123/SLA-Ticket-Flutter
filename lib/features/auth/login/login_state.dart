part of 'login_cubit.dart';

enum LoginStep { credentials, twoFactor }

final class LoginState extends Equatable {
  const LoginState({
    this.step = LoginStep.credentials,
    this.submitting = false,
    this.useRecoveryCode = false,
    this.error,
    this.fieldErrors = const {},
  });

  final LoginStep step;
  final bool submitting;

  /// On the 2FA step: whether the admin is typing a recovery code instead of
  /// a code from their authenticator app.
  final bool useRecoveryCode;

  /// A message for the whole form, e.g. when the server is unreachable.
  final String? error;

  /// Validation messages from Laravel, keyed by field (`email`, `code`, ...).
  final Map<String, String> fieldErrors;

  LoginState copyWith({
    LoginStep? step,
    bool? submitting,
    bool? useRecoveryCode,
    String? Function()? error,
    Map<String, String>? fieldErrors,
  }) => LoginState(
    step: step ?? this.step,
    submitting: submitting ?? this.submitting,
    useRecoveryCode: useRecoveryCode ?? this.useRecoveryCode,
    error: error != null ? error() : this.error,
    fieldErrors: fieldErrors ?? this.fieldErrors,
  );

  @override
  List<Object?> get props => [
    step,
    submitting,
    useRecoveryCode,
    error,
    fieldErrors,
  ];
}
