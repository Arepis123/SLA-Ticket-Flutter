import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sla_ticket_flutter/data/models/session.dart';
import 'package:sla_ticket_flutter/data/repositories/auth_repository.dart';
import 'package:sla_ticket_flutter/features/auth/bloc/auth_bloc.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late StreamController<void> expired;

  const session = Session.demo();

  setUpAll(() => registerFallbackValue(session));

  setUp(() {
    repository = _MockAuthRepository();
    expired = StreamController<void>.broadcast();
    when(() => repository.forget()).thenAnswer((_) async {});
    when(() => repository.signOut(any())).thenAnswer((_) async {});
  });

  tearDown(() => expired.close());

  AuthBloc build() =>
      AuthBloc(repository: repository, sessionExpired: expired.stream);

  blocTest<AuthBloc, AuthState>(
    'opens on the login screen when nothing is saved',
    setUp: () => when(() => repository.restore()).thenAnswer((_) async => null),
    build: build,
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => const [AuthState.unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'restores a saved session',
    setUp: () =>
        when(() => repository.restore()).thenAnswer((_) async => session),
    build: build,
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => const [AuthState.authenticated(session)],
  );

  blocTest<AuthBloc, AuthState>(
    'signs out once when the server rejects the token, however many requests fail',
    build: build,
    seed: () => const AuthState.authenticated(session),
    act: (_) {
      expired
        ..add(null)
        ..add(null);
    },
    wait: Duration.zero,
    expect: () => const [AuthState.unauthenticated(expired: true)],
    verify: (_) => verify(() => repository.forget()).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'revokes the session on sign out',
    build: build,
    seed: () => const AuthState.authenticated(session),
    act: (bloc) => bloc.add(const AuthSignOutRequested()),
    expect: () => const [AuthState.unauthenticated()],
    verify: (_) => verify(() => repository.signOut(session)).called(1),
  );
}
