import 'package:flutter/material.dart';

/// Width of the left screen edge that starts a back-swipe gesture.
const kEdgeSwipeBackWidth = 24.0;

/// Minimum horizontal drag (logical px) to trigger back.
const kEdgeSwipeBackDragTrigger = 56.0;

/// Returns whether the app can navigate back (route pop or dismiss modal).
bool triftlyCanGoBack(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).canPop();
}

/// Pops the current route or dismisses the top modal — same as the system back button.
void triftlyGoBack(BuildContext context) {
  if (!triftlyCanGoBack(context)) return;
  Navigator.of(context, rootNavigator: true).pop();
}

/// Wraps [child] with a left-edge horizontal swipe that calls [onBack] or [triftlyGoBack].
///
/// Place on stacked routes via [triftlyPage], and on modal sheets (sheets sit above
/// the page stack, so they need their own wrap — see [TriftlyBottomSheet]).
class EdgeSwipeBack extends StatefulWidget {
  const EdgeSwipeBack({
    required this.child,
    this.onBack,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onBack;
  final bool enabled;

  @override
  State<EdgeSwipeBack> createState() => _EdgeSwipeBackState();
}

class _EdgeSwipeBackState extends State<EdgeSwipeBack> {
  bool _startedOnEdge = false;
  double _dragTotal = 0;
  bool _triggered = false;

  void _resetTracking() {
    _startedOnEdge = false;
    _dragTotal = 0;
    _triggered = false;
  }

  void _tryBack() {
    if (_triggered || !mounted) return;
    final onBack = widget.onBack;
    if (onBack != null) {
      _triggered = true;
      onBack();
      return;
    }
    if (!triftlyCanGoBack(context)) return;
    _triggered = true;
    triftlyGoBack(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: kEdgeSwipeBackWidth,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              _resetTracking();
              _startedOnEdge = true;
            },
            onPointerMove: (event) {
              if (!_startedOnEdge || _triggered) return;
              if (event.delta.dx <= 0) return;
              _dragTotal += event.delta.dx;
              if (_dragTotal >= kEdgeSwipeBackDragTrigger) {
                _tryBack();
              }
            },
            onPointerUp: (_) => _resetTracking(),
            onPointerCancel: (_) => _resetTracking(),
          ),
        ),
      ],
    );
  }
}