import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Subtle press feedback — no scale gimmicks.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    required this.onTap,
    this.haptic = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.72 : 1,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
