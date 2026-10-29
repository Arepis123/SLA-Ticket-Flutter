import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/sla_palette.dart';
import '../../../data/models/dashboard.dart';
import '../../../data/repositories/monitor_repository.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/ticket_card.dart';
import '../../shell/account_menu.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/breakdown_list.dart';
import '../widgets/kpi_grid.dart';
import '../widgets/trend_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DashboardCubit(repository: context.read<MonitorRepository>())..load(),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [AccountMenu()],
      ),
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listenWhen: (previous, current) =>
            current.error != null &&
            current.error != previous.error &&
            current.dashboard != null,
        listener: (context, state) => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.error!))),
        builder: (context, state) {
          final dashboard = state.dashboard;

          if (dashboard != null) return _DashboardContent(dashboard);

          if (state.status == DashboardStatus.failure) {
            return _LoadError(
              message: state.error ?? 'Could not load the dashboard.',
              onRetry: () => context.read<DashboardCubit>().load(),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent(this.dashboard);

  final Dashboard dashboard;

  static const _priorityLabels = {
    'critical': 'Critical',
    'high': 'High',
    'medium': 'Medium',
    'low': 'Low',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(
            'Updated ${DateFormat.Hm().format(dashboard.generatedAt.toLocal())} · pull to refresh',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          KpiGrid(stats: dashboard.stats),
          const SectionHeader('Needs attention'),
          if (dashboard.attention.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.celebration_outlined),
                title: Text('Nothing urgent right now.'),
              ),
            )
          else
            for (final ticket in dashboard.attention)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TicketCard(ticket: ticket),
              ),
          const SectionHeader('Opened per day'),
          TrendChart(points: dashboard.trend),
          const SectionHeader('Open by priority'),
          BreakdownList(
            rows: [
              for (final MapEntry(key: priority, value: count)
                  in dashboard.byPriority.entries)
                BreakdownRow(
                  label: _priorityLabels[priority] ?? priority,
                  count: count,
                  color: SlaPalette.forPriority(priority),
                ),
            ],
          ),
          const SectionHeader('Busiest systems'),
          BreakdownList(
            rows: [
              for (final load in dashboard.byProject)
                BreakdownRow(
                  label: load.project.name,
                  caption: load.company.name,
                  count: load.count,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
