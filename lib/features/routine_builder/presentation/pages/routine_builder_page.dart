import 'package:flutter/material.dart';
import 'package:triftly/core/extensions/localizations.dart';

class RoutineBuilderPage extends StatelessWidget {
  const RoutineBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              context.l10n.page_routine_builder,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
