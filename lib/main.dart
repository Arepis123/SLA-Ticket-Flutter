import 'dart:io';

import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/session_storage.dart';
import 'data/demo/demo_monitor_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/monitor_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final client = ApiClient(baseUrl: config.apiBaseUrl);

  final authRepository = AuthRepository(
    client: client,
    storage: SessionStorage(),
    deviceName: 'SLA Monitor (${Platform.operatingSystem})',
  );

  final authBloc = AuthBloc(
    repository: authRepository,
    sessionExpired: client.unauthorized,
  )..add(const AuthStarted());

  final monitorRepository = SessionMonitorRepository(
    live: ApiMonitorRepository(client),
    demo: DemoMonitorRepository(),
    isDemo: () => authBloc.state.session?.isDemo ?? false,
  );

  runApp(
    SlaMonitorApp(
      config: config,
      authRepository: authRepository,
      monitorRepository: monitorRepository,
      authBloc: authBloc,
    ),
  );
}
