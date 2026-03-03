import 'package:flutter/material.dart';
import 'package:triftly/core/theme/app_colors.dart';
import 'package:triftly/features/routine_builder/presentation/widgets/routine_day_page.dart';
import 'package:triftly/widgets/bottom_sheets/routine_builder_bottom_sheet/routine_builder_bottom_sheet.dart';

/// PageView with dot indicator + swipe hint so users know they can swipe.
class RoutineDayCarousel extends StatefulWidget {
  const RoutineDayCarousel({super.key, required this.trip});

  final RoutineTripResult trip;

  @override
  State<RoutineDayCarousel> createState() => _RoutineDayCarouselState();
}

class _RoutineDayCarouselState extends State<RoutineDayCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.trip.daysOfTrip;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        _SwipeIndicator(
          pageCount: count,
          currentPage: _currentPage,
          primary: primary,
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: count,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final date = widget.trip.startDate.add(Duration(days: index));
              return RoutineDayPage(
                dayIndex: index,
                date: date,
                totalDays: count,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SwipeIndicator extends StatelessWidget {
  const _SwipeIndicator({
    required this.pageCount,
    required this.currentPage,
    required this.primary,
  });

  final int pageCount;
  final int currentPage;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pageCount,
          (index) {
            final isActive = index == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 12 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isActive
                      ? primary
                      : AppColors.mistGray.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
