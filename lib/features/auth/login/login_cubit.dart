import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/auth_repository.dart';

part 'login_state.dart';

/// The sign-in form: email and password first, then a two-factor code when
/// the account has one. Hands the finished session to [onSignedIn].
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this._repository, required this._onSignedIn})
    : super(const LoginState());

  final AuthRepository _repository;
  final void Function(Session session) _onSignedIn;

  // Kept between the two steps: the server checks the password again along
  // with the code, so no half-signed-in state lives on the server.
  String _email = '';
  String _password = '';

  Future<void> submitCredentials(String email, String password) {
    _email = email.trim();
    _password = password;

    return _submit();
  }

  Future<void> submitCode(String code) {
    final value = code.trim();

    return state.useRecoveryCode
        ? _submit(recoveryCode: value)
        : _submit(code: value.replaceAll(' ', ''));
  }

  void toggleRecoveryCode() => emit(
    state.copyWith(
      useRecoveryCode: !state.useRecoveryCode,
      error: () => null,
      fieldErrors: const {},
    ),
  );

  void backToCredentials() {
    _password = '';
    emit(const LoginState());
  }

  void startDemo() => _onSignedIn(_repository.startDemo());

  Future<void> _submit({String? code, String? recoveryCode}) async {
    emit(
      state.copyWith(
        submitting: true,
        error: () => null,
        fieldErrors: const {},
      ),
    );

    try {
      final result = await _repository.signIn(
        email: _email,
        password: _password,
        code: code,
        recoveryCode: recoveryCode,
      );

      switch (result) {
        case SignedIn(:final session):
          emit(state.copyWith(submitting: false));
          _onSignedIn(session);
        case TwoFactorRequired():
          emit(state.copyWith(submitting: false, step: LoginStep.twoFactor));
      }
    } on ApiException catch (error) {
      final fieldErrors = {
        for (final MapEntry(:key, :value) in error.fieldErrors.entries)
          if (value.isNotEmpty) key: value.first,
      };

      emit(
        state.copyWith(
          submitting: false,
          fieldErrors: fieldErrors,
          error: () => fieldErrors.isEmpty ? error.message : null,
        ),
      );
    }
  }
}
