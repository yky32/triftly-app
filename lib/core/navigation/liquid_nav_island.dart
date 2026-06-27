import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/session/session_bloc.dart';
import '../constants/app_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/glass_surface.dart';

/// Compact floating nav island — sliding pill, icon-first, label on active tab.
class LiquidNavIsland extends StatefulWidget {
  const LiquidNavIsland({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<LiquidNavIsland> createState() => _LiquidNavIslandState();
}

class _LiquidNavIslandState extends State<LiquidNavIsland> with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..value = 1;
  }

  @override
  void didUpdateWidget(LiquidNavIsland oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = AppPage.navBarPages;

    return GlassSurface(
      blur: 36,
      bordered: false,
      borderRadius: AppRadii.navIslandRadius,
      padding: const EdgeInsets.all(5),
      child: BlocBuilder<SessionBloc, SessionState>(
        buildWhen: (prev, next) => prev.isCloudSignedIn != next.isCloudSignedIn,
        builder: (context, session) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final slotWidth = constraints.maxWidth / pages.length;
              const inset = 2.0;

              return SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                      left: widget.currentIndex * slotWidth + inset,
                      top: inset,
                      bottom: inset,
                      width: slotWidth - inset * 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: AppRadii.navIslandSlotRadius,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.88),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: pages.map((page) {
                        final index = page.shellBranchIndex!;
                        final selected = index == widget.currentIndex;
                        return Expanded(
                          child: _NavSlot(
                            page: page,
                            selected: selected,
                            isCloudSignedIn: session.isCloudSignedIn,
                            bounce: selected ? _bounce : null,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              widget.onTap(index);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.page,
    required this.selected,
    required this.isCloudSignedIn,
    required this.onTap,
    this.bounce,
  });

  final AppPage page;
  final bool selected;
  final bool isCloudSignedIn;
  final VoidCallback onTap;
  final Animation<double>? bounce;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryDark : AppColors.textTertiary;

    Widget icon = Icon(
      page.resolveNavIcon(selected: selected, isCloudSignedIn: isCloudSignedIn),
      size: selected ? 23 : 21,
      color: color,
    );

    if (bounce != null) {
      icon = ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1).animate(
          CurvedAnimation(parent: bounce!, curve: Curves.easeOutBack),
        ),
        child: icon,
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.navIslandSlotRadius,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: 48,
          child: Center(child: icon),
        ),
      ),
    );
  }
}
