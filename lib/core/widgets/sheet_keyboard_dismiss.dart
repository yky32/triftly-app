import 'package:flutter/material.dart';

/// Dismisses the keyboard when the user taps sheet chrome outside a focused field.
class SheetKeyboardDismiss extends StatelessWidget {
  const SheetKeyboardDismiss({required this.child, super.key});

  final Widget child;

  static void unfocus() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null && focus.hasFocus) {
      focus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unfocus,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
