import 'package:flutter/material.dart';

/// Colours for SLA states and priorities, matching the web app's badges.
abstract final class SlaPalette {
  static Color forState(String state) => switch (state) {
    'breached' => const Color(0xFFDC2626),
    'at_risk' => const Color(0xFFD97706),
    'on_track' => const Color(0xFF16A34A),
    'met' => const Color(0xFF059669),
    _ => const Color(0xFF71717A), // paused, merged
  };

  static IconData iconForState(String state) => switch (state) {
    'breached' => Icons.cancel_outlined,
    'at_risk' => Icons.warning_amber_rounded,
    'on_track' => Icons.schedule,
    'met' => Icons.check_circle_outline,
    'paused' => Icons.pause_circle_outline,
    _ => Icons.call_merge,
  };

  static Color forPriority(String priority) => switch (priority) {
    'critical' => const Color(0xFFDC2626),
    'high' => const Color(0xFFEA580C),
    'medium' => const Color(0xFFCA8A04),
    _ => const Color(0xFF71717A),
  };
}
