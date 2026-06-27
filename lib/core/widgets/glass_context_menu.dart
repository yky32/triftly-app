import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'glass_surface.dart';
import 'spend_glass_shell.dart';

class GlassMenuEntry<T> {
  const GlassMenuEntry({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool destructive;
}

/// Frosted popup menu anchored to a trigger widget — liquid glass feel.
abstract final class GlassContextMenu {
  static const _menuWidth = 168.0;

  static Future<T?> show<T>({
    required BuildContext context,
    required List<GlassMenuEntry<T>> entries,
    double width = _menuWidth,
  }) {
    final box = context.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
    final screen = overlay.size;

    final left = (origin.dx + box.size.width - width).clamp(8.0, screen.width - width - 8);
    final top = origin.dy + box.size.height + 6;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss menu',
      barrierColor: Colors.black.withValues(alpha: 0.06),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, _, __) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: width,
              child: _GlassMenuPanel<T>(
                entries: entries,
                onSelected: (value) => Navigator.of(dialogContext).pop(value),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curve),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );
  }
}

class _GlassMenuPanel<T> extends StatelessWidget {
  const _GlassMenuPanel({
    required this.entries,
    required this.onSelected,
  });

  final List<GlassMenuEntry<T>> entries;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight.withValues(alpha: 0.85);

    return Material(
      type: MaterialType.transparency,
      child: GlassSurface(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        blur: 28,
        tint: SpendGlassShell.tint(isDark),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0) Divider(height: 1, thickness: 1, color: dividerColor),
              _GlassMenuRow(
                entry: entries[i],
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(entries[i].value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassMenuRow extends StatelessWidget {
  const _GlassMenuRow({
    required this.entry,
    required this.onTap,
  });

  final GlassMenuEntry<dynamic> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = entry.destructive
        ? AppColors.error
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              if (entry.icon != null) ...[
                Icon(entry.icon, size: 18, color: color),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  entry.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
