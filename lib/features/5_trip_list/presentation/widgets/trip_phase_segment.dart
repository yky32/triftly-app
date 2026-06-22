import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'trip_phase_style.dart';

/// Segmented control to filter trips by phase.
class TripPhaseSegment extends StatelessWidget {
  const TripPhaseSegment({
    required this.selected,
    required this.counts,
    required this.onChanged,
    super.key,
  });

  final TripPhase selected;
  final Map<TripPhase, int> counts;
  final ValueChanged<TripPhase> onChanged;

  static final _labels = {
    TripPhase.inProgress: 'Active',
    TripPhase.upcoming: 'Upcoming',
    TripPhase.completed: 'Done',
  };

  static final _icons = {
    TripPhase.inProgress: Icons.flight_takeoff_rounded,
    TripPhase.upcoming: Icons.event_rounded,
    TripPhase.completed: Icons.check_circle_rounded,
  };

  static final _iconsOutlined = {
    TripPhase.inProgress: Icons.flight_takeoff_outlined,
    TripPhase.upcoming: Icons.event_outlined,
    TripPhase.completed: Icons.check_circle_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phases = TripPhase.values;
    final selectedStyle = TripPhaseStyle.of(selected);
    final isLive = selected == TripPhase.inProgress;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / phases.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: selected.index * slotWidth,
                top: 0,
                bottom: 0,
                width: slotWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (isLive)
                      Positioned.fill(
                        child: _LiveRipple(
                          color: selectedStyle.foreground(isDark),
                        ),
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: selectedStyle.pill(isDark),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        boxShadow: [
                          BoxShadow(
                            color: selectedStyle.foreground(isDark).withValues(
                                  alpha: isLive ? (isDark ? 0.28 : 0.18) : (isDark ? 0.2 : 0.12),
                                ),
                            blurRadius: isLive ? 14 : 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: phases.map((phase) {
                  final isSelected = phase == selected;
                  final count = counts[phase] ?? 0;
                  final style = TripPhaseStyle.of(phase);
                  final fg = isSelected ? style.foreground(isDark) : AppColors.textTertiary;
                  final showLiveDot = phase == TripPhase.inProgress && isSelected;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (phase == selected) return;
                        HapticFeedback.selectionClick();
                        onChanged(phase);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showLiveDot) ...[
                              _LiveDot(color: fg),
                              const SizedBox(width: 4),
                            ],
                            Icon(
                              isSelected ? _icons[phase]! : _iconsOutlined[phase]!,
                              size: 16,
                              color: fg,
                            ),
                            const SizedBox(width: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: fg,
                              ),
                              child: Text(_labels[phase]!),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 5),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? style.badge(isDark)
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  borderRadius: BorderRadius.circular(AppRadii.pill),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: fg,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Expanding rings behind the Active pill when selected.
class _LiveRipple extends StatefulWidget {
  const _LiveRipple({required this.color});

  final Color color;

  @override
  State<_LiveRipple> createState() => _LiveRippleState();
}

class _LiveRippleState extends State<_LiveRipple> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < 2; i++) _RippleRing(
              progress: (_controller.value + i * 0.5) % 1.0,
              color: widget.color,
            ),
          ],
        );
      },
    );
  }
}

class _RippleRing extends StatelessWidget {
  const _RippleRing({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - progress) * 0.45;
    final scale = 0.92 + progress * 0.28;

    return Transform.scale(
      scale: scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: color.withValues(alpha: opacity), width: 1.5),
        ),
      ),
    );
  }
}

/// Pulsing dot beside the Active label.
class _LiveDot extends StatefulWidget {
  const _LiveDot({required this.color});

  final Color color;

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.75 + _controller.value * 0.35;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
