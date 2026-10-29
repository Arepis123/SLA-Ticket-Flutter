import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sla_ticket_flutter/core/network/api_exception.dart';
import 'package:sla_ticket_flutter/data/demo/demo_monitor_repository.dart';
import 'package:sla_ticket_flutter/data/models/dashboard.dart';
import 'package:sla_ticket_flutter/data/repositories/monitor_repository.dart';
import 'package:sla_ticket_flutter/features/dashboard/cubit/dashboard_cubit.dart';

class _MockMonitorRepository extends Mock implements MonitorRepository {}

void main() {
  late _MockMonitorRepository repository;
  late Dashboard dashboard;

  setUpAll(() async {
    dashboard = await DemoMonitorRepository(latency: Duration.zero)
        .fetchDashboard();
  });

  setUp(() => repository = _MockMonitorRepository());

  DashboardCubit build() =>
      DashboardCubit(repository: repository, autoRefresh: null);

  blocTest<DashboardCubit, DashboardState>(
    'loads the dashboard',
    setUp: () =>
        when(() => repository.fetchDashboard())
            .thenAnswer((_) async => dashboard),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const DashboardState(status: DashboardStatus.loading),
      DashboardState(status: DashboardStatus.success, dashboard: dashboard),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'shows the error when the first load fails',
    setUp: () =>
        when(() => repository.fetchDashboard())
            .thenThrow(const ApiException('Offline')),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => const [
      DashboardState(status: DashboardStatus.loading),
      DashboardState(status: DashboardStatus.failure, error: 'Offline'),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'keeps the last data on screen when a refresh fails',
    setUp: () =>
        when(() => repository.fetchDashboard())
            .thenThrow(const ApiException('Offline')),
    build: build,
    seed: () =>
        DashboardState(status: DashboardStatus.success, dashboard: dashboard),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      DashboardState(
        status: DashboardStatus.success,
        dashboard: dashboard,
        refreshing: true,
      ),
      DashboardState(
        status: DashboardStatus.success,
        dashboard: dashboard,
        error: 'Offline',
      ),
    ],
  );
}
