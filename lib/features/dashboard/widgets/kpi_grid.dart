import 'package:flutter/material.dart';

import '../../../core/theme/sla_palette.dart';
import '../../../data/models/dashboard.dart';

/// The headline numbers, two per row on a phone.
class KpiGrid extends StatelessWidget {
  const KpiGrid({required this.stats, super.key});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final tiles = [
      _Kpi(
        'Open',
        '${stats.open}',
        '${stats.unassigned} unassigned',
        Icons.inbox_outlined,
        scheme.primary,
      ),
      _Kpi(
        'Breached',
        '${stats.breached}',
        'past an SLA target',
        Icons.cancel_outlined,
        SlaPalette.forState('breached'),
      ),
      _Kpi(
        'At risk',
        '${stats.atRisk}',
        'close to the deadline',
        Icons.warning_amber_rounded,
        SlaPalette.forState('at_risk'),
      ),
      _Kpi(
        'SLA met',
        stats.compliance == null ? '—' : '${stats.compliance}%',
        '${stats.resolved30d} resolved in 30 days',
        Icons.verified_outlined,
        SlaPalette.forState('met'),
      ),
      _Kpi(
        'Avg response',
        stats.avgResponse ?? '—',
        'last 30 days',
        Icons.reply_outlined,
        scheme.tertiary,
      ),
      _Kpi(
        'Avg resolution',
        stats.avgResolution ?? '—',
        'clock time, minus pauses',
        Icons.timer_outlined,
        scheme.tertiary,
      ),
      _Kpi(
        'Pending client',
        '${stats.pendingClient}',
        'SLA clock paused',
        Icons.pause_circle_outline,
        SlaPalette.forState('paused'),
      ),
      _Kpi(
        'Awaiting confirmation',
        '${stats.awaitingConfirmation}',
        'resolved, not yet confirmed',
        Icons.task_alt,
        scheme.secondary,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 116,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) => _KpiTile(tiles[index]),
    );
  }
}

class _Kpi {
  const _Kpi(this.label, this.value, this.hint, this.icon, this.color);

  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final Color color;
}

class _KpiTile extends StatelessWidget {
  const _KpiTile(this.kpi);

  final _Kpi kpi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(kpi.icon, size: 18, color: kpi.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    kpi.label,
                    style: theme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              kpi.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              kpi.hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
