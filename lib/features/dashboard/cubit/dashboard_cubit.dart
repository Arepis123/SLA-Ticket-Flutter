import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/dashboard.dart';
import '../../../data/repositories/monitor_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  /// Refreshes on its own every [autoRefresh]; pass null to turn that off.
  DashboardCubit({
    required this._repository,
    Duration? autoRefresh = const Duration(minutes: 1),
  }) : super(const DashboardState()) {
    if (autoRefresh != null) {
      _timer = Timer.periodic(autoRefresh, (_) => refresh());
    }
  }

  final MonitorRepository _repository;
  Timer? _timer;

  /// First load: shows a spinner until data arrives.
  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading, error: () => null));
    await _fetch();
  }

  /// Pull-to-refresh and the timer: keeps the current data on screen.
  Future<void> refresh() async {
    if (state.refreshing || state.status == DashboardStatus.loading) return;

    if (state.dashboard == null) return load();

    emit(state.copyWith(refreshing: true, error: () => null));
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final dashboard = await _repository.fetchDashboard();
      if (isClosed) return;

      emit(
        DashboardState(status: DashboardStatus.success, dashboard: dashboard),
      );
    } on ApiException catch (error) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: state.dashboard == null ? DashboardStatus.failure : null,
          refreshing: false,
          error: () => error.message,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
