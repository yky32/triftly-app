import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'glass_surface.dart';

/// Frosted pill toggle — matches [GlassSurface] / liquid nav island styling.
class GlassToggle extends StatelessWidget {
  const GlassToggle({
    required this.value,
    required this.onChanged,
    this.bare = false,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool bare;

  static const outerWidth = 50.0;
  static const outerHeight = 30.0;
  static const _inset = 3.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbSize = outerHeight - _inset * 2;

    final track = _ToggleTrack(
      value: value,
      isDark: isDark,
      thumbSize: thumbSize,
    );

    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: outerWidth,
          height: outerHeight,
          child: bare
              ? Padding(padding: const EdgeInsets.all(_inset), child: track)
              : GlassSurface(
                  blur: 24,
                  borderRadius: BorderRadius.circular(outerHeight / 2),
                  padding: const EdgeInsets.all(_inset),
                  tint: value
                      ? AppColors.primary.withValues(alpha: isDark ? 0.32 : 0.2)
                      : (isDark
                          ? const Color(0xFF1C1C1E).withValues(alpha: 0.5)
                          : const Color(0xFFFEFEFE).withValues(alpha: 0.45)),
                  child: track,
                ),
        ),
      ),
    );
  }
}

class _ToggleTrack extends StatelessWidget {
  const _ToggleTrack({
    required this.value,
    required this.isDark,
    required this.thumbSize,
  });

  final bool value;
  final bool isDark;
  final double thumbSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final travel = constraints.maxWidth - thumbSize;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: value ? travel : 0,
              top: 0,
              width: thumbSize,
              height: thumbSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.94)
                      : Colors.white.withValues(alpha: 0.96),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: value ? 0.18 : 0.06),
                      blurRadius: value ? 10 : 6,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
