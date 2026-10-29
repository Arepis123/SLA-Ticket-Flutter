import '../../core/network/api_client.dart';
import '../models/dashboard.dart';

/// Read-only monitoring data. Screens depend on this interface only, so the
/// same BLoCs run against the live API, demo data or a test fake.
abstract interface class MonitorRepository {
  Future<Dashboard> fetchDashboard();
}

class ApiMonitorRepository implements MonitorRepository {
  ApiMonitorRepository(this._client);

  final ApiClient _client;

  @override
  Future<Dashboard> fetchDashboard() async =>
      Dashboard.fromJson(await _client.get('admin/dashboard'));
}

/// Sends each call to the live or demo repository depending on the session,
/// so the rest of the app never has to know which one it is using.
class SessionMonitorRepository implements MonitorRepository {
  SessionMonitorRepository({
    required this._live,
    required this._demo,
    required this._isDemo,
  });

  final MonitorRepository _live;
  final MonitorRepository _demo;
  final bool Function() _isDemo;

  MonitorRepository get _active => _isDemo() ? _demo : _live;

  @override
  Future<Dashboard> fetchDashboard() => _active.fetchDashboard();
}
