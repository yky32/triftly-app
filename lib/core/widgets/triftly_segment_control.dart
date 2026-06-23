import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/segment_style.dart';

/// One slot in [TriftlySegmentControl] — label, icons, tone, optional count / live dot.
class SegmentItem {
  const SegmentItem({
    required this.label,
    required this.iconFilled,
    required this.iconOutlined,
    required this.toneIndex,
    this.count,
    this.showLiveIndicator = false,
  });

  final String label;
  final IconData iconFilled;
  final IconData iconOutlined;
  final int toneIndex;
  final int? count;
  final bool showLiveIndicator;

  SegmentStyle get style => SegmentStyle.toneAt(toneIndex);
}

/// Pill segmented control shared by trip phase filter and trip detail tabs.
class TriftlySegmentControl extends StatelessWidget {
  const TriftlySegmentControl({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<SegmentItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedItem = items[selectedIndex];
    final selectedStyle = selectedItem.style;
    final showLiveRipple = selectedItem.showLiveIndicator;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / items.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: selectedIndex * slotWidth,
                top: 0,
                bottom: 0,
                width: slotWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (showLiveRipple)
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
                                  alpha: showLiveRipple
                                      ? (isDark ? 0.28 : 0.18)
                                      : (isDark ? 0.2 : 0.12),
                                ),
                            blurRadius: showLiveRipple ? 14 : 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = index == selectedIndex;
                  final style = item.style;
                  final fg = isSelected ? style.foreground(isDark) : AppColors.textTertiary;
                  final count = item.count ?? 0;
                  final showLiveDot = item.showLiveIndicator && isSelected;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isSelected) return;
                        HapticFeedback.selectionClick();
                        onChanged(index);
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
                              isSelected ? item.iconFilled : item.iconOutlined,
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
                              child: Text(item.label),
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
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
            for (var i = 0; i < 2; i++)
              _RippleRing(
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
