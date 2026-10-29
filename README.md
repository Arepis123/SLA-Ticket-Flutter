# SLA Monitor

A Flutter app for administrators of the SLA-Ticket support system: live SLA
status, tickets that need attention, and service trends, on iOS and Android.
It reads from the Laravel API in the SLA-Ticket repository and is read-only by
design.

## Run it

```sh
flutter pub get

# Against a server (the Laravel app's root URL, without /api)
flutter run --dart-define=API_BASE_URL=https://sla.example.com

# No server? Tap "Explore with demo data" on the sign-in screen.
flutter run
```

On a physical phone, `localhost` is the phone itself: use your Mac's LAN
address (e.g. `http://192.168.1.20:8000`) or a deployed URL.

## Architecture

```
lib/
├── main.dart          wiring: API client → repositories → AuthBloc → app
├── app/               MaterialApp, theme, go_router with auth redirects
├── core/              config, Dio API client and errors, secure session storage
├── data/
│   ├── models/        immutable Equatable models parsed from the API
│   ├── repositories/  AuthRepository, MonitorRepository (live ↔ demo)
│   └── demo/          built-in sample data
└── features/
    ├── auth/          AuthBloc (app session) and LoginCubit (password → 2FA)
    ├── dashboard/     DashboardCubit, page and widgets
    └── shell/         bottom navigation, account menu
```

- **State management:** `flutter_bloc`. `AuthBloc` owns the session and drives
  routing; each screen has its own Cubit that depends only on a repository
  interface.
- **Demo mode:** `SessionMonitorRepository` sends calls to the live API or to
  `DemoMonitorRepository` depending on the session, so no screen knows or cares
  which one it is using.
- **Security:** tokens live in the iOS Keychain / Android Keystore. Sign-in
  goes through the server's two-factor check, tokens expire after 30 days, and
  any 401 signs the app out.
- **SLA logic stays on the server.** Business hours, holidays and paused time
  are worked out by Laravel; the app shows the result instead of reimplementing it.

## Tests

```sh
flutter test
```

Model tests run against real API responses in `test/fixtures/`, so the app
and the API cannot drift apart unnoticed. BLoC tests use `bloc_test` and
`mocktail`.
