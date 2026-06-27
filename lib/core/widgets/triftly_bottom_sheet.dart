import 'package:flutter/material.dart';
import '../navigation/edge_swipe_back.dart';
import 'sheet_keyboard_dismiss.dart';

/// Shared modal bottom sheet launcher — matches trip/tool sheet chrome.
abstract final class TriftlyBottomSheet {
  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => EdgeSwipeBack(
        child: SheetKeyboardDismiss(child: child),
      ),
    );
  }
}
