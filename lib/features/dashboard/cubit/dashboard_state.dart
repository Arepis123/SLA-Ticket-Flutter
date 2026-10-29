part of 'dashboard_cubit.dart';

enum DashboardStatus { initial, loading, success, failure }

final class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.dashboard,
    this.refreshing = false,
    this.error,
  });

  final DashboardStatus status;

  /// The last data that loaded. It stays on screen while a refresh runs and
  /// after a refresh fails, so a flaky connection never blanks the screen.
  final Dashboard? dashboard;
  final bool refreshing;
  final String? error;

  DashboardState copyWith({
    DashboardStatus? status,
    Dashboard? dashboard,
    bool? refreshing,
    String? Function()? error,
  }) => DashboardState(
    status: status ?? this.status,
    dashboard: dashboard ?? this.dashboard,
    refreshing: refreshing ?? this.refreshing,
    error: error != null ? error() : this.error,
  );

  @override
  List<Object?> get props => [status, dashboard, refreshing, error];
}
