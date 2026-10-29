import 'package:equatable/equatable.dart';

import 'app_user.dart';
import 'labeled.dart';

/// Who is signed in, and whether the app talks to the real API or demo data.
class Session extends Equatable {
  const Session({
    required this.user,
    this.token,
    this.expiresAt,
    this.isDemo = false,
  });

  /// A session backed by built-in sample data, for trying the app without an
  /// account on a real server.
  const Session.demo()
    : user = const AppUser(
        id: 0,
        name: 'Demo Admin',
        email: 'demo@example.com',
        initials: 'DA',
        role: Labeled('admin', 'Admin'),
      ),
      token = null,
      expiresAt = null,
      isDemo = true;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    token: json['token'] as String?,
    expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
  );

  final AppUser user;
  final String? token;
  final DateTime? expiresAt;
  final bool isDemo;

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'token': token,
    'expires_at': expiresAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [user, token, expiresAt, isDemo];
}
