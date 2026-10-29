import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sla_ticket_flutter/data/demo/demo_monitor_repository.dart';
import 'package:sla_ticket_flutter/data/models/session.dart';
import 'package:sla_ticket_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:sla_ticket_flutter/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:sla_ticket_flutter/features/dashboard/view/dashboard_page.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  testWidgets('renders the demo dashboard with breached tickets first', (
    tester,
  ) async {
    final authBloc = _MockAuthBloc();
    when(
      () => authBloc.state,
    ).thenReturn(const AuthState.authenticated(Session.demo()));

    final cubit = DashboardCubit(
      repository: DemoMonitorRepository(latency: Duration.zero),
      autoRefresh: null,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider.value(value: cubit..load()),
          ],
          child: const DashboardView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Breached'), findsWidgets);
    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('Payment gateway timeout on checkout'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
  });
}
