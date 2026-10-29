import 'package:flutter/material.dart';

/// Rows of label, proportional bar and count, e.g. open tickets per priority.
class BreakdownList extends StatelessWidget {
  const BreakdownList({required this.rows, super.key});

  final List<BreakdownRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final peak = rows.fold(0, (max, row) => row.count > max ? row.count : max);

    if (rows.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Nothing open.', style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.label,
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (row.caption != null)
                            Text(
                              row.caption!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: peak == 0 ? 0 : row.count / peak,
                          minHeight: 8,
                          color: row.color,
                          backgroundColor: row.color.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${row.count}',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BreakdownRow {
  const BreakdownRow({
    required this.label,
    required this.count,
    required this.color,
    this.caption,
  });

  final String label;
  final String? caption;
  final int count;
  final Color color;
}
