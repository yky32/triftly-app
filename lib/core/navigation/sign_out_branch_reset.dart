import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/session/session_bloc.dart';

/// Pops nested shell routes when cloud sign-out ends (e.g. trip detail → trip list).
///
/// [StatefulShellRoute.indexedStack] keeps branch pages mounted while another tab
/// is visible, so this must live on stacked pages — not only on the tab root.
class SignOutBranchReset extends StatelessWidget {
  const SignOutBranchReset({required this.child, super.key});

  final Widget child;

  static void popToBranchRoot(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (prev, next) => prev.isCloudSignedIn && !next.isCloudSignedIn,
      listener: (context, _) => popToBranchRoot(context),
      child: child,
    );
  }
}
