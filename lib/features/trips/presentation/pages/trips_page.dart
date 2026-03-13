import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/routine_builder/data/routine_repository.dart';
import 'package:triftly/features/trips/bloc/trips_bloc.dart';

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripsBloc(
        repository: context.read<RoutineRepository>(),
      ),
      child: const _TripsView(),
    );
  }
}

class _TripsView extends StatelessWidget {
  const _TripsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          context.l10n.page_my_trips,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => context
                                  .read<TripsBloc>()
                                  .add(const TripsReloadRequested()),
                              icon: Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              tooltip: 'Refresh trips',
                              padding: const EdgeInsets.only(right: 6),
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              visualDensity: const VisualDensity(
                                horizontal: -3,
                                vertical: -3,
                              ),
                            ),
                            Text(
                              context.l10n.trips_view_all,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _TripsSearchBar(hintText: context.l10n.trips_search_hint),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<TripsBloc, TripsState>(
                  builder: (context, state) {
                    final isLoading = state.isLoading;
                    return GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      behavior: HitTestBehavior.opaque,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const crossAxisSpacing = 12.0;
                          const mainAxisSpacing = 12.0;
                          const crossAxisCount = 2;
                          const itemHeight = 240.0;
                          final visibleRows =
                              ((constraints.maxHeight + mainAxisSpacing) /
                                      (itemHeight + mainAxisSpacing))
                                  .ceil();
                          final skeletonCount =
                              (visibleRows <= 0 ? 1 : visibleRows) *
                                  crossAxisCount;

                          final items = isLoading
                              ? List<_TripItem>.generate(
                                  skeletonCount,
                                  (_) => const _TripItem.placeholder(),
                                )
                              : state.trips
                                  .map((trip) =>
                                      _TripItem.fromSavedTrip(context, trip))
                                  .toList();

                          if (!isLoading && items.isEmpty) {
                            return Center(
                              child: Text(
                                'No saved trips yet',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }

                          final itemWidth =
                              (constraints.maxWidth - crossAxisSpacing) /
                                  crossAxisCount;
                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: itemWidth / 240,
                              crossAxisSpacing: crossAxisSpacing,
                              mainAxisSpacing: mainAxisSpacing,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _TripCard(
                                item: items[index],
                                isLoading: isLoading,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripItem {
  const _TripItem({
    required this.name,
    required this.country,
    required this.dateLabel,
  });

  const _TripItem.placeholder()
      : name = 'Trip to Japan',
        country = 'Japan',
        dateLabel = '01/04/2026 - 01/10/2026';

  factory _TripItem.fromSavedTrip(
    BuildContext context,
    SavedTripSummary trip,
  ) {
    final localizations = MaterialLocalizations.of(context);
    final startLabel = localizations.formatShortDate(trip.startDate);
    final endLabel = localizations.formatShortDate(trip.endDate);
    final dateLabel =
        trip.startDate == trip.endDate ? startLabel : '$startLabel - $endLabel';

    return _TripItem(
      name: trip.name.trim().isEmpty ? 'Untitled trip' : trip.name,
      country:
          trip.countries.isEmpty ? 'No country' : trip.countries.join(', '),
      dateLabel: dateLabel,
    );
  }

  final String name;
  final String country;
  final String dateLabel;
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.item, this.isLoading = false});

  final _TripItem item;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Skeletonizer(
      enabled: isLoading,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.tealMist.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.landscape_rounded,
                  size: 36,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.flag_rounded,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.country,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.dateLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        context.l10n.trips_show_details,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search bar with animated focus / non-focus effects.
class _TripsSearchBar extends StatefulWidget {
  const _TripsSearchBar({required this.hintText});

  final String hintText;

  @override
  State<_TripsSearchBar> createState() => _TripsSearchBarState();
}

class _TripsSearchBarState extends State<_TripsSearchBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFocused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isFocused
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isFocused
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            size: 22,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
