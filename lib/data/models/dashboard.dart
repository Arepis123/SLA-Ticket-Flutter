import 'package:equatable/equatable.dart';

import 'labeled.dart';
import 'ticket.dart';

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.open,
    required this.unassigned,
    required this.atRisk,
    required this.breached,
    required this.pendingClient,
    required this.awaitingConfirmation,
    required this.resolved30d,
    this.compliance,
    this.avgResponse,
    this.avgResolution,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
    open: json['open'] as int,
    unassigned: json['unassigned'] as int,
    atRisk: json['at_risk'] as int,
    breached: json['breached'] as int,
    pendingClient: json['pending_client'] as int,
    awaitingConfirmation: json['awaiting_confirmation'] as int,
    resolved30d: json['resolved_30d'] as int,
    // PHP's round() returns a float, so this may arrive as 87.0.
    compliance: (json['compliance'] as num?)?.round(),
    avgResponse: json['avg_response'] as String?,
    avgResolution: json['avg_resolution'] as String?,
  );

  final int open;
  final int unassigned;
  final int atRisk;
  final int breached;
  final int pendingClient;
  final int awaitingConfirmation;
  final int resolved30d;

  /// Percent of tickets resolved in the last 30 days that met their SLA.
  final int? compliance;

  /// Short labels such as "1h 20m"; null when there is nothing to average.
  final String? avgResponse;
  final String? avgResolution;

  @override
  List<Object?> get props => [
    open,
    unassigned,
    atRisk,
    breached,
    pendingClient,
    awaitingConfirmation,
    resolved30d,
    compliance,
    avgResponse,
    avgResolution,
  ];
}

class ProjectLoad extends Equatable {
  const ProjectLoad({
    required this.project,
    required this.company,
    required this.count,
  });

  factory ProjectLoad.fromJson(Map<String, dynamic> json) => ProjectLoad(
    project: NamedRef.fromJson(json['project'] as Map<String, dynamic>),
    company: NamedRef.fromJson(json['company'] as Map<String, dynamic>),
    count: json['count'] as int,
  );

  final NamedRef project;
  final NamedRef company;
  final int count;

  @override
  List<Object?> get props => [project, company, count];
}

class TrendPoint extends Equatable {
  const TrendPoint({
    required this.date,
    required this.label,
    required this.count,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
    date: DateTime.parse(json['date'] as String),
    label: json['label'] as String,
    count: json['count'] as int,
  );

  final DateTime date;
  final String label;
  final int count;

  @override
  List<Object?> get props => [date, label, count];
}

class Dashboard extends Equatable {
  const Dashboard({
    required this.stats,
    required this.attention,
    required this.byPriority,
    required this.byProject,
    required this.trend,
    required this.generatedAt,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
    stats: DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
    attention: (json['attention'] as List)
        .map((item) => Ticket.fromJson(item as Map<String, dynamic>))
        .toList(),
    byPriority: (json['by_priority'] as Map<String, dynamic>).map(
      (priority, count) => MapEntry(priority, count as int),
    ),
    byProject: (json['by_project'] as List)
        .map((item) => ProjectLoad.fromJson(item as Map<String, dynamic>))
        .toList(),
    trend: (json['trend'] as List)
        .map((item) => TrendPoint.fromJson(item as Map<String, dynamic>))
        .toList(),
    generatedAt: DateTime.parse(json['generated_at'] as String),
  );

  final DashboardStats stats;

  /// Unresolved tickets to look at first: breached, then nearest deadline.
  final List<Ticket> attention;

  /// Unresolved tickets per priority value, most urgent first.
  final Map<String, int> byPriority;
  final List<ProjectLoad> byProject;

  /// Tickets opened per day over the last 14 days.
  final List<TrendPoint> trend;
  final DateTime generatedAt;

  @override
  List<Object?> get props => [
    stats,
    attention,
    byPriority,
    byProject,
    trend,
    generatedAt,
  ];
}
