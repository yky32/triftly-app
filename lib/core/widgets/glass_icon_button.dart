import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'glass_surface.dart';

/// Frosted icon button — pairs with [GlassToggle] in app bars and toolbars.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 34,
    this.bare = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.primaryLight : AppColors.primaryDark;

    final iconWidget = Icon(icon, size: size * 0.5, color: iconColor);

    final button = Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: size,
          height: size,
          child: bare
              ? Center(child: iconWidget)
              : GlassSurface(
                  blur: 24,
                  borderRadius: BorderRadius.circular(size * 0.36),
                  padding: EdgeInsets.zero,
                  tint: isDark
                      ? const Color(0xFF1C1C1E).withValues(alpha: 0.5)
                      : const Color(0xFFFEFEFE).withValues(alpha: 0.45),
                  child: Center(child: iconWidget),
                ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Groups glass controls in one frosted capsule (e.g. summary toggle + share).
class GlassToolbarCluster extends StatelessWidget {
  const GlassToolbarCluster({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      blur: 26,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      tint: isDark
          ? const Color(0xFF1C1C1E).withValues(alpha: 0.55)
          : const Color(0xFFFEFEFE).withValues(alpha: 0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
