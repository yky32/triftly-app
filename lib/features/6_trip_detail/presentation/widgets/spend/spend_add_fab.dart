import 'package:flutter/material.dart';

class SpendAddFab extends StatelessWidget {
  const SpendAddFab({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Expense'),
    );
  }
}
