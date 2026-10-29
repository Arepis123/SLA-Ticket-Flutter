/// Settings fixed at build time with `--dart-define`, for example:
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=https://sla.example.com
/// ```
class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() => const AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000',
    ),
  );

  /// Root URL of the Laravel app, without the `/api` suffix.
  final String apiBaseUrl;
}
