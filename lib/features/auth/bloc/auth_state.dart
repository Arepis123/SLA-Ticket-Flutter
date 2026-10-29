part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

final class AuthState extends Equatable {
  const AuthState._({required this.status, this.session, this.expired = false});

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated(Session session)
    : this._(status: AuthStatus.authenticated, session: session);

  /// [expired] is true when the server ended the session, so the login
  /// screen can explain why the admin is back there.
  const AuthState.unauthenticated({bool expired = false})
    : this._(status: AuthStatus.unauthenticated, expired: expired);

  final AuthStatus status;
  final Session? session;
  final bool expired;

  @override
  List<Object?> get props => [status, session, expired];
}
