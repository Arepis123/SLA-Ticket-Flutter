import 'package:equatable/equatable.dart';

/// An enum value from the server with its display label, such as a status
/// (`in_progress` / "In Progress"). Labels come from Laravel so the app and
/// the web app always use the same wording.
class Labeled extends Equatable {
  const Labeled(this.value, this.label);

  factory Labeled.fromJson(Map<String, dynamic> json) =>
      Labeled(json['value'] as String, json['label'] as String);

  final String value;
  final String label;

  Map<String, dynamic> toJson() => {'value': value, 'label': label};

  @override
  List<Object?> get props => [value, label];
}

/// A reference to a related record, such as a ticket's company or assignee.
class NamedRef extends Equatable {
  const NamedRef(this.id, this.name);

  factory NamedRef.fromJson(Map<String, dynamic> json) =>
      NamedRef(json['id'] as int, json['name'] as String);

  static NamedRef? maybeFromJson(Object? json) =>
      json is Map<String, dynamic> ? NamedRef.fromJson(json) : null;

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
