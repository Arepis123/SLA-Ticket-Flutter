import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sla_ticket_flutter/core/network/api_exception.dart';
import 'package:sla_ticket_flutter/data/models/session.dart';
import 'package:sla_ticket_flutter/data/repositories/auth_repository.dart';
import 'package:sla_ticket_flutter/features/auth/login/login_cubit.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late List<Session> signedIn;

  const session = Session.demo();

  setUp(() {
    repository = _MockAuthRepository();
    signedIn = [];
  });

  LoginCubit build() =>
      LoginCubit(repository: repository, onSignedIn: signedIn.add);

  void answer(Future<SignInResult> Function(Invocation) result) => when(
    () => repository.signIn(
      email: any(named: 'email'),
      password: any(named: 'password'),
      code: any(named: 'code'),
      recoveryCode: any(named: 'recoveryCode'),
    ),
  ).thenAnswer(result);

  blocTest<LoginCubit, LoginState>(
    'signs straight in when the account has no two-factor authentication',
    setUp: () => answer((_) async => const SignedIn(session)),
    build: build,
    act: (cubit) => cubit.submitCredentials(' admin@example.com ', 'secret'),
    expect: () => const [LoginState(submitting: true), LoginState()],
    verify: (_) {
      expect(signedIn, [session]);
      verify(
        () => repository.signIn(email: 'admin@example.com', password: 'secret'),
      ).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'asks for a code, then resends the password with it',
    setUp: () => answer(
      (invocation) async => invocation.namedArguments[#code] == null
          ? const TwoFactorRequired()
          : const SignedIn(session),
    ),
    build: build,
    act: (cubit) async {
      await cubit.submitCredentials('admin@example.com', 'secret');
      await cubit.submitCode('123 456');
    },
    expect: () => const [
      LoginState(submitting: true),
      LoginState(step: LoginStep.twoFactor),
      LoginState(step: LoginStep.twoFactor, submitting: true),
      LoginState(step: LoginStep.twoFactor),
    ],
    verify: (_) {
      expect(signedIn, [session]);
      verify(
        () => repository.signIn(
          email: 'admin@example.com',
          password: 'secret',
          code: '123456',
        ),
      ).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'sends a recovery code when the admin switches to one',
    setUp: () => answer((_) async => const SignedIn(session)),
    build: build,
    seed: () => const LoginState(step: LoginStep.twoFactor),
    act: (cubit) async {
      cubit.toggleRecoveryCode();
      await cubit.submitCode('abcd-efgh');
    },
    verify: (_) => verify(
      () =>
          repository.signIn(email: '', password: '', recoveryCode: 'abcd-efgh'),
    ).called(1),
  );

  blocTest<LoginCubit, LoginState>(
    'shows validation errors next to their fields',
    setUp: () => answer(
      (_) async => throw const ApiException(
        'The given data was invalid.',
        statusCode: 422,
        fieldErrors: {
          'email': ['These credentials do not match our records.'],
        },
      ),
    ),
    build: build,
    act: (cubit) => cubit.submitCredentials('admin@example.com', 'wrong'),
    expect: () => const [
      LoginState(submitting: true),
      LoginState(
        fieldErrors: {'email': 'These credentials do not match our records.'},
      ),
    ],
    verify: (_) => expect(signedIn, isEmpty),
  );

  blocTest<LoginCubit, LoginState>(
    'shows a form-wide error when the server cannot be reached',
    setUp: () => answer(
      (_) async => throw const ApiException("Can't reach the server."),
    ),
    build: build,
    act: (cubit) => cubit.submitCredentials('admin@example.com', 'secret'),
    expect: () => const [
      LoginState(submitting: true),
      LoginState(error: "Can't reach the server."),
    ],
  );
}
