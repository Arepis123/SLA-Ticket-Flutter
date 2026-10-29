import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/session.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// The app-wide session. The router listens to it to decide between the
/// login screen and the signed-in shell.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this._repository, required Stream<void> sessionExpired})
    : super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignedIn>(_onSignedIn);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthSessionExpired>(_onSessionExpired);

    _expiredSubscription = sessionExpired.listen(
      (_) => add(const AuthSessionExpired()),
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<void> _expiredSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final session = await _repository.restore();

    emit(
      session == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(session),
    );
  }

  void _onSignedIn(AuthSignedIn event, Emitter<AuthState> emit) =>
      emit(AuthState.authenticated(event.session));

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final session = state.session;
    if (session != null) await _repository.signOut(session);

    emit(const AuthState.unauthenticated());
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    // Several requests can fail together; only the first one signs out.
    if (state.status != AuthStatus.authenticated) return;

    await _repository.forget();
    emit(const AuthState.unauthenticated(expired: true));
  }

  @override
  Future<void> close() async {
    await _expiredSubscription.cancel();
    return super.close();
  }
}
