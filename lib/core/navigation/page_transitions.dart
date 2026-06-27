import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'edge_swipe_back.dart';

CustomTransitionPage<T> triftlyPage<T>({
  required GoRouterState state,
  required Widget child,
  VoidCallback? onEdgeSwipeBack,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: EdgeSwipeBack(
      onBack: onEdgeSwipeBack,
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}
