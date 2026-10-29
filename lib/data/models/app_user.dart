import 'package:equatable/equatable.dart';

import 'labeled.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    initials: json['initials'] as String,
    role: Labeled.fromJson(json['role'] as Map<String, dynamic>),
  );

  final int id;
  final String name;
  final String email;
  final String initials;
  final Labeled role;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'initials': initials,
    'role': role.toJson(),
  };

  @override
  List<Object?> get props => [id, name, email, initials, role];
}
