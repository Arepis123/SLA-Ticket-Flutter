import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sla_ticket_flutter/data/models/app_user.dart';
import 'package:sla_ticket_flutter/data/models/dashboard.dart';

/// The fixtures are real responses from the Laravel API (see
/// test/fixtures/README.md), so these tests catch the two sides drifting apart.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('parses the dashboard response', () {
    final dashboard = Dashboard.fromJson(fixture('dashboard'));

    expect(dashboard.stats.open, 2);
    expect(dashboard.stats.breached, 1);
    expect(dashboard.stats.compliance, 100);
    expect(dashboard.byPriority, {
      'critical': 1,
      'high': 0,
      'medium': 0,
      'low': 1,
    });
    expect(dashboard.trend, hasLength(14));

    final first = dashboard.attention.first;
    expect(first.sla.state.value, 'breached');
    expect(first.sla.progress, greaterThan(100));
    expect(first.sla.resolutionDueAt, isNotNull);
    expect(first.company, isNotNull);
    expect(first.assignee, isNull);
  });

  test('accepts compliance sent as a float', () {
    final json = fixture('dashboard');
    (json['stats'] as Map<String, dynamic>)['compliance'] = 87.0;

    expect(Dashboard.fromJson(json).stats.compliance, 87);
  });

  test('parses the signed-in user and round-trips it for storage', () {
    final user = AppUser.fromJson(
      fixture('me')['data'] as Map<String, dynamic>,
    );

    expect(user.role.value, 'admin');
    expect(AppUser.fromJson(user.toJson()), user);
  });
}
