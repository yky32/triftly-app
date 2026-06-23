import 'package:flutter/material.dart';

/// Shared modal bottom sheet launcher — matches trip/tool sheet chrome.
abstract final class TriftlyBottomSheet {
  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }
}
