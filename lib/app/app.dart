import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/monitor_repository.dart';
import '../features/auth/bloc/auth_bloc.dart';
import 'router.dart';

class SlaMonitorApp extends StatefulWidget {
  const SlaMonitorApp({
    required this.config,
    required this.authRepository,
    required this.monitorRepository,
    required this.authBloc,
    super.key,
  });

  final AppConfig config;
  final AuthRepository authRepository;
  final MonitorRepository monitorRepository;
  final AuthBloc authBloc;

  @override
  State<SlaMonitorApp> createState() => _SlaMonitorAppState();
}

class _SlaMonitorAppState extends State<SlaMonitorApp> {
  // Created once: rebuilding the router would reset navigation.
  late final GoRouter _router = createRouter(widget.authBloc);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.config),
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.monitorRepository),
      ],
      child: BlocProvider.value(
        value: widget.authBloc,
        child: MaterialApp.router(
          title: 'SLA Monitor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          routerConfig: _router,
        ),
      ),
    );
  }
}
