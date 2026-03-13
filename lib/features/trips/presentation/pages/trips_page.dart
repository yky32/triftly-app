import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/routine_builder/data/routine_repository.dart';
import 'package:triftly/features/trips/bloc/trips_bloc.dart';
import 'package:triftly/features/trips/presentation/widgets/bottom_sheets/trip_details_bottom_sheet.dart';

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
                          const mainAxisSpacing = 8.0;
                          const crossAxisCount = 2;
                          const itemHeight = 170.0;
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
                            padding: const EdgeInsets.only(bottom: 16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: itemWidth / 170,
                              crossAxisSpacing: crossAxisSpacing,
                              mainAxisSpacing: mainAxisSpacing,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _TripCard(
                                item: items[index],
                                isLoading: isLoading,
                                onTap: items[index].source != null
                                    ? () => TripDetailsBottomSheet.show(
                                          context,
                                          items[index].source!,
                                        )
                                    : null,
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
    required this.daysCount,
    required this.source,
  });

  const _TripItem.placeholder()
      : name = 'Trip to Japan',
        country = 'Japan',
        dateLabel = 'Apr 1 – Apr 10',
        daysCount = 10,
        source = null;

  factory _TripItem.fromSavedTrip(
    BuildContext context,
    SavedTripSummary trip,
  ) {
    final localizations = MaterialLocalizations.of(context);
    final startLabel = localizations.formatShortDate(trip.startDate);
    final endLabel = localizations.formatShortDate(trip.endDate);
    final dateLabel =
        trip.startDate == trip.endDate ? startLabel : '$startLabel – $endLabel';
    final daysCount = trip.endDate.difference(trip.startDate).inDays + 1;

    return _TripItem(
      name: trip.name.trim().isEmpty ? 'Untitled trip' : trip.name,
      country:
          trip.countries.isEmpty ? 'No country' : trip.countries.join(', '),
      dateLabel: dateLabel,
      daysCount: daysCount,
      source: trip,
    );
  }

  final String name;
  final String country;
  final String dateLabel;
  final int daysCount;
  /// The original [SavedTripSummary]; null for placeholder skeleton items.
  final SavedTripSummary? source;
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.item,
    this.isLoading = false,
    this.onTap,
  });

  final _TripItem item;
  final bool isLoading;
  final VoidCallback? onTap;

  // Assign a banner gradient per card cycling through brand palette
  static const List<List<Color>> _gradients = [
    [AppColors.deepTeal, AppColors.driftTeal],
    [AppColors.driftTeal, AppColors.calmGreen],
    [Color(0xFF0E7490), AppColors.driftTeal],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gradient = _gradients[
        (item.name.codeUnitAt(0) + item.daysCount) % _gradients.length];
    final dayLabel =
        item.daysCount == 1 ? '1 day' : '${item.daysCount} days';

    return Skeletonizer(
      enabled: isLoading,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          splashColor: AppColors.driftTeal.withValues(alpha: 0.12),
          highlightColor: AppColors.driftTeal.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.28),
                  blurRadius: 24,
                  spreadRadius: -2,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.12),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Banner ──────────────────────────────────────────────
                SizedBox(
                  height: 88,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // gradient
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // decorative circle top-right
                      Positioned(
                        right: -24,
                        top: -24,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // decorative circle bottom-left
                      Positioned(
                        left: -16,
                        bottom: -28,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      // icon
                      const Center(
                        child: Icon(
                          Icons.terrain_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                      // days pill – top right
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            dayLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ────────────────────────────────────────────────
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.fogGray.withValues(alpha: 0.10),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // trip name
                        Text(
                          item.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // country row
                        _MetaRow(
                          icon: Icons.place_rounded,
                          label: item.country,
                          iconColor: AppColors.driftTeal,
                        ),
                        const SizedBox(height: 3),
                        // date row
                        _MetaRow(
                          icon: Icons.date_range_rounded,
                          label: item.dateLabel,
                          iconColor: AppColors.softAmber,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.3,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
