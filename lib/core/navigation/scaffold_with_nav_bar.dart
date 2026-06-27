import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cloud_sync/cloud_sync_bloc.dart';
import '../bloc/session/session_bloc.dart';
import '../constants/app_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'liquid_nav_island.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Compact centered island — not edge-to-edge (2026 pattern).
    final islandWidth = (screenWidth * 0.88).clamp(280.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      extendBody: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: navigationShell),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.navIslandBottomOffset(context),
            child: Center(
              child: SizedBox(
                width: islandWidth,
                child: LiquidNavIsland(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) {
                    final planIndex = AppPage.plan.shellBranchIndex!;
                    final switchingToPlan =
                        index == planIndex && navigationShell.currentIndex != planIndex;

                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );

                    if (switchingToPlan) {
                      _syncTripsOnTabFocus(context);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _syncTripsOnTabFocus(BuildContext context) {
  final session = context.read<SessionBloc>().state;
  if (!session.isCloudSignedIn) return;

  final syncBloc = context.read<CloudSyncBloc>();
  if (syncBloc.state.isSyncing) return;

  syncBloc.add(const CloudSyncRetryRequested());
}
