import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/features/routine_builder/bloc/routine_builder_bloc.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/routine_day_carousel.dart';
import 'package:triftly/widgets/bottom_sheets/routine_builder_bottom_sheet/routine_builder_bottom_sheet.dart';

class RoutineBuilderPage extends StatelessWidget {
  const RoutineBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoutineBuilderBloc(),
      child: const _RoutineBuilderView(),
    );
  }
}

class _RoutineBuilderView extends StatelessWidget {
  const _RoutineBuilderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: BlocBuilder<RoutineBuilderBloc, RoutineBuilderState>(
            builder: (context, state) {
              final hasTrip = state.trip != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, onAdd: () => _openTripSheet(context)),
                  if (hasTrip)
                    Expanded(
                      child: RoutineDayCarousel(trip: state.trip!),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: Text(
                          'Select trip dates to see day-by-day pages',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required VoidCallback onAdd}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            context.l10n.page_routine_builder,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }

  Future<void> _openTripSheet(BuildContext context) async {
    final result = await RoutineBuilderBottomSheet.show(context);
    if (result != null && context.mounted) {
      context.read<RoutineBuilderBloc>().add(TripSelected(result));
    }
  }
}
