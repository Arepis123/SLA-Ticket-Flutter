part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// App launch: look for a session saved on this device.
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSignedIn extends AuthEvent {
  const AuthSignedIn(this.session);

  final Session session;

  @override
  List<Object?> get props => [session];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// The server rejected the token: it expired, was revoked, or the admin was
/// deactivated.
final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
