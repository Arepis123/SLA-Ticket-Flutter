import '../models/dashboard.dart';
import '../models/labeled.dart';
import '../models/ticket.dart';
import '../repositories/monitor_repository.dart';

/// Built-in sample data for demo mode. Every client, system and person is
/// made up; times are relative to "now" so the SLA countdowns stay believable.
class DemoMonitorRepository implements MonitorRepository {
  DemoMonitorRepository({
    this.latency = const Duration(milliseconds: 400),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Simulated network delay, so loading states are visible in the demo.
  final Duration latency;
  final DateTime Function() _clock;

  static const _companies = [
    NamedRef(1, 'Northwind Logistics'),
    NamedRef(2, 'Bayu Health'),
    NamedRef(3, 'Kinabalu Retail'),
    NamedRef(4, 'Seri Mutiara Bank'),
  ];

  static const _projects = [
    NamedRef(1, 'Fleet Portal'),
    NamedRef(2, 'Patient App'),
    NamedRef(3, 'POS Cloud'),
    NamedRef(4, 'Mobile Banking'),
  ];

  static const _staff = [
    NamedRef(1, 'Aina Rahman'),
    NamedRef(2, 'Daniel Tan'),
    NamedRef(3, 'Mei Ling'),
    NamedRef(4, 'Ravi Kumar'),
  ];

  static const _priorities = {
    'critical': Labeled('critical', 'Critical'),
    'high': Labeled('high', 'High'),
    'medium': Labeled('medium', 'Medium'),
    'low': Labeled('low', 'Low'),
  };

  static const _states = {
    'on_track': Labeled('on_track', 'On track'),
    'at_risk': Labeled('at_risk', 'At risk'),
    'breached': Labeled('breached', 'Breached'),
    'paused': Labeled('paused', 'Paused'),
  };

  @override
  Future<Dashboard> fetchDashboard() async {
    await Future<void>.delayed(latency);

    final now = _clock();
    final tickets = _openTickets(now);
    final attention =
        tickets
            .where((ticket) => ticket.status.value != 'pending_client')
            .toList()
          ..sort((a, b) {
            final breached = (b.sla.state.value == 'breached' ? 1 : 0)
                .compareTo(a.sla.state.value == 'breached' ? 1 : 0);
            return breached != 0
                ? breached
                : a.sla.resolutionDueAt!.compareTo(b.sla.resolutionDueAt!);
          });

    int countState(String state) =>
        tickets.where((ticket) => ticket.sla.state.value == state).length;

    final byProject = <int, ProjectLoad>{};
    for (final ticket in tickets) {
      final current = byProject[ticket.project!.id];
      byProject[ticket.project!.id] = ProjectLoad(
        project: ticket.project!,
        company: ticket.company!,
        count: (current?.count ?? 0) + 1,
      );
    }

    // A steady, slightly bumpy two weeks of new tickets.
    const opened = [4, 6, 3, 7, 5, 2, 1, 6, 8, 4, 5, 9, 3, 4];

    return Dashboard(
      stats: DashboardStats(
        open: tickets.length,
        unassigned: tickets.where((ticket) => ticket.assignee == null).length,
        atRisk: countState('at_risk'),
        breached: countState('breached'),
        pendingClient: tickets
            .where((ticket) => ticket.status.value == 'pending_client')
            .length,
        awaitingConfirmation: 3,
        resolved30d: 42,
        compliance: 88,
        avgResponse: '47m',
        avgResolution: '1d 3h',
      ),
      attention: attention.take(5).toList(),
      byPriority: {
        for (final priority in _priorities.keys)
          priority: tickets
              .where((ticket) => ticket.priority.value == priority)
              .length,
      },
      byProject: byProject.values.toList()
        ..sort((a, b) => b.count.compareTo(a.count)),
      trend: [
        for (var i = 0; i < opened.length; i++)
          _trendPoint(
            now.subtract(Duration(days: opened.length - 1 - i)),
            opened[i],
          ),
      ],
      generatedAt: now,
    );
  }

  List<Ticket> _openTickets(DateTime now) {
    // (title, priority, sla state, status, company/project index, assignee
    // index or null, hours since opened, hours until resolution due)
    const rows = <(String, String, String, String, int, int?, int, int)>[
      (
        'Payment gateway timeout on checkout',
        'critical',
        'breached',
        'in_progress',
        2,
        0,
        11,
        -3,
      ),
      (
        'Drivers cannot upload proof of delivery',
        'high',
        'breached',
        'acknowledged',
        0,
        1,
        30,
        -6,
      ),
      (
        'Appointment reminders sent twice',
        'high',
        'at_risk',
        'in_progress',
        1,
        2,
        19,
        5,
      ),
      (
        'Login loop after password reset',
        'critical',
        'at_risk',
        'open',
        3,
        null,
        6,
        2,
      ),
      (
        'Monthly statement PDF missing logo',
        'low',
        'on_track',
        'open',
        3,
        null,
        20,
        148,
      ),
      (
        'Stock count off after offline sync',
        'medium',
        'on_track',
        'in_progress',
        2,
        3,
        26,
        46,
      ),
      (
        'Route map slow to load on Android',
        'medium',
        'on_track',
        'acknowledged',
        0,
        1,
        8,
        64,
      ),
      (
        'Lab results page shows wrong timezone',
        'medium',
        'paused',
        'pending_client',
        1,
        2,
        50,
        30,
      ),
      (
        'Export to Excel drops last row',
        'low',
        'on_track',
        'open',
        2,
        null,
        3,
        165,
      ),
      (
        'Push notifications not arriving on iOS',
        'high',
        'on_track',
        'reopened',
        3,
        0,
        4,
        20,
      ),
      (
        'Need access for new branch manager',
        'low',
        'paused',
        'pending_client',
        0,
        3,
        70,
        98,
      ),
    ];

    const statuses = {
      'open': Labeled('open', 'Open'),
      'acknowledged': Labeled('acknowledged', 'Acknowledged'),
      'in_progress': Labeled('in_progress', 'In Progress'),
      'pending_client': Labeled('pending_client', 'Pending Client'),
      'reopened': Labeled('reopened', 'Reopened'),
    };

    return [
      for (final (index, row) in rows.indexed)
        () {
          final (title, priority, state, status, client, assignee, age, dueIn) =
              row;
          final created = now.subtract(Duration(hours: age));
          final due = now.add(Duration(hours: dueIn));
          final window = due.difference(created).inMinutes;

          return Ticket(
            id: 100 + index,
            reference:
                'TKT-${now.year}-${(214 + index).toString().padLeft(5, '0')}',
            title: title,
            status: statuses[status]!,
            priority: _priorities[priority]!,
            category: const Labeled('bug', 'Bug'),
            sla: SlaInfo(
              state: _states[state]!,
              progress: window <= 0 ? 100 : age * 60 / window * 100,
              countdown: _countdown(dueIn),
              resolutionDueAt: due,
              paused: state == 'paused',
            ),
            company: _companies[client],
            project: _projects[client],
            assignee: assignee == null ? null : _staff[assignee],
            reporter: const NamedRef(99, 'Client User'),
            createdAt: created,
            updatedAt: now.subtract(Duration(minutes: 7 * index)),
          );
        }(),
    ];
  }

  static String _countdown(int hours) {
    final span = hours.abs() >= 48
        ? '${hours.abs() ~/ 24} days'
        : '${hours.abs()} hours';
    return hours < 0 ? 'Overdue by $span' : '$span left';
  }

  static TrendPoint _trendPoint(DateTime day, int count) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return TrendPoint(
      date: DateTime(day.year, day.month, day.day),
      label: '${day.day.toString().padLeft(2, '0')} ${months[day.month - 1]}',
      count: count,
    );
  }
}
