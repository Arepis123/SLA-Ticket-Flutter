import 'package:equatable/equatable.dart';

import 'labeled.dart';

/// SLA values the server has worked out for a ticket. They depend on business
/// hours, holidays and paused time, so the app shows them rather than
/// recomputing them.
class SlaInfo extends Equatable {
  const SlaInfo({
    required this.state,
    required this.progress,
    required this.countdown,
    this.responseDueAt,
    this.resolutionDueAt,
    this.responseBreached = false,
    this.paused = false,
    this.outsideBusinessHours = false,
  });

  factory SlaInfo.fromJson(Map<String, dynamic> json) => SlaInfo(
    state: Labeled.fromJson(json['state'] as Map<String, dynamic>),
    progress: (json['progress'] as num).toDouble(),
    countdown: json['countdown'] as String,
    responseDueAt: _date(json['response_due_at']),
    resolutionDueAt: _date(json['resolution_due_at']),
    responseBreached: json['response_breached'] as bool? ?? false,
    paused: json['paused'] as bool? ?? false,
    outsideBusinessHours: json['outside_business_hours'] as bool? ?? false,
  );

  /// One of `on_track`, `at_risk`, `breached`, `paused`, `met` or `merged`.
  final Labeled state;

  /// Share of the resolution window used, in percent (can exceed 100).
  final double progress;

  /// Server-written label such as "3 hours left" or "Overdue by 2 days".
  final String countdown;
  final DateTime? responseDueAt;
  final DateTime? resolutionDueAt;
  final bool responseBreached;
  final bool paused;
  final bool outsideBusinessHours;

  @override
  List<Object?> get props => [
    state,
    progress,
    countdown,
    responseDueAt,
    resolutionDueAt,
    responseBreached,
    paused,
    outsideBusinessHours,
  ];
}

class Ticket extends Equatable {
  const Ticket({
    required this.id,
    required this.reference,
    required this.title,
    required this.status,
    required this.priority,
    required this.category,
    required this.sla,
    required this.createdAt,
    required this.updatedAt,
    this.company,
    this.project,
    this.assignee,
    this.reporter,
    this.mergedInto,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json['id'] as int,
    reference: json['reference'] as String,
    title: json['title'] as String,
    status: Labeled.fromJson(json['status'] as Map<String, dynamic>),
    priority: Labeled.fromJson(json['priority'] as Map<String, dynamic>),
    category: Labeled.fromJson(json['category'] as Map<String, dynamic>),
    sla: SlaInfo.fromJson(json['sla'] as Map<String, dynamic>),
    company: NamedRef.maybeFromJson(json['company']),
    project: NamedRef.maybeFromJson(json['project']),
    assignee: NamedRef.maybeFromJson(json['assignee']),
    reporter: NamedRef.maybeFromJson(json['reporter']),
    mergedInto: json['merged_into'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  final int id;
  final String reference;
  final String title;
  final Labeled status;
  final Labeled priority;
  final Labeled category;
  final SlaInfo sla;
  final NamedRef? company;
  final NamedRef? project;
  final NamedRef? assignee;
  final NamedRef? reporter;
  final String? mergedInto;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    reference,
    title,
    status,
    priority,
    category,
    sla,
    company,
    project,
    assignee,
    reporter,
    mergedInto,
    createdAt,
    updatedAt,
  ];
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
