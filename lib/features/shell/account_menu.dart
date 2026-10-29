import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/bloc/auth_bloc.dart';

/// The signed-in admin's avatar, with sign-out. Shows a "Demo" badge in demo
/// mode so screenshots are never mistaken for real client data.
class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.select((AuthBloc bloc) => bloc.state.session);
    if (session == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (session.isDemo)
          Chip(
            label: const Text('Demo'),
            visualDensity: VisualDensity.compact,
            backgroundColor: scheme.tertiaryContainer,
            side: BorderSide.none,
          ),
        PopupMenuButton<void>(
          tooltip: 'Account',
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              session.user.initials,
              style: TextStyle(fontSize: 12, color: scheme.onPrimaryContainer),
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(session.user.name),
                subtitle: Text(session.user.email),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              onTap: () =>
                  context.read<AuthBloc>().add(const AuthSignOutRequested()),
              child: Text(session.isDemo ? 'Leave demo' : 'Sign out'),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
