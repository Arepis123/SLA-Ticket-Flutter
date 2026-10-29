import 'package:flutter/material.dart';

import '../../core/theme/sla_palette.dart';
import '../../data/models/ticket.dart';
import 'status_pill.dart';

/// A ticket in a list: what it is, who has it, and how its SLA is doing.
class TicketCard extends StatelessWidget {
  const TicketCard({required this.ticket, this.onTap, super.key});

  final Ticket ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ticket.sla.state;
    final slaColor = SlaPalette.forState(state.value);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ticket.reference,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Spacer(),
                  StatusPill(
                    label: ticket.priority.label,
                    color: SlaPalette.forPriority(ticket.priority.value),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.title,
                style: theme.textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                [
                  ticket.project?.name,
                  ticket.company?.name,
                  ticket.assignee?.name ?? 'Unassigned',
                ].nonNulls.join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StatusPill(
                    label: state.label,
                    color: slaColor,
                    icon: SlaPalette.iconForState(state.value),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ticket.sla.countdown,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (ticket.sla.progress / 100).clamp(0, 1),
                  minHeight: 4,
                  color: slaColor,
                  backgroundColor: slaColor.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
