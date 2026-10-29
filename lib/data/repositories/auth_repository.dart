import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/session_storage.dart';
import '../models/app_user.dart';
import '../models/session.dart';

/// Result of sending credentials: either a session, or a request for a
/// two-factor code before the server will issue a token.
sealed class SignInResult {
  const SignInResult();
}

final class SignedIn extends SignInResult {
  const SignedIn(this.session);

  final Session session;
}

final class TwoFactorRequired extends SignInResult {
  const TwoFactorRequired();
}

class AuthRepository {
  AuthRepository({
    required this._client,
    required this._storage,
    this.deviceName = 'SLA Monitor',
  });

  final ApiClient _client;
  final SessionStorage _storage;

  /// Shown on the server's token list, so admins can tell devices apart.
  final String deviceName;

  /// The session saved on this device, if any. It is used as-is so the app
  /// opens offline; a token the server no longer accepts triggers a sign-out
  /// on the first request instead.
  Future<Session?> restore() async {
    final session = await _storage.read();

    if (session == null) return null;

    if (session.expiresAt?.isBefore(DateTime.now()) ?? false) {
      await _storage.clear();
      return null;
    }

    _client.token = session.token;
    return session;
  }

  /// Send email and password, plus a TOTP [code] or [recoveryCode] once the
  /// server has answered with [TwoFactorRequired].
  ///
  /// Throws [ApiException] for wrong credentials, non-admin accounts or an
  /// invalid code; its field errors say which.
  Future<SignInResult> signIn({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
  }) async {
    final body = await _client.post(
      'auth/token',
      data: {
        'email': email,
        'password': password,
        'device_name': deviceName,
        'code': ?code,
        'recovery_code': ?recoveryCode,
      },
    );

    if (body['two_factor'] == true) return const TwoFactorRequired();

    final session = Session(
      user: AppUser.fromJson(body['user'] as Map<String, dynamic>),
      token: body['token'] as String,
      expiresAt: DateTime.tryParse(body['expires_at'] as String? ?? ''),
    );

    await _storage.write(session);
    _client.token = session.token;

    return SignedIn(session);
  }

  Session startDemo() => const Session.demo();

  /// Revoke the token on the server when possible, and always forget it here.
  Future<void> signOut(Session session) async {
    if (!session.isDemo) {
      try {
        await _client.delete('auth/token');
      } on ApiException {
        // Offline or already revoked: the local sign-out still goes ahead.
      }
    }

    await forget();
  }

  /// Drop the local session without contacting the server, e.g. once the
  /// server has already rejected the token.
  Future<void> forget() async {
    _client.token = null;
    await _storage.clear();
  }
}
