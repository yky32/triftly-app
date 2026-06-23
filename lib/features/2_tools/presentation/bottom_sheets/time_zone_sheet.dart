import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_zone_options.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../../../../core/widgets/triftly_motion.dart';

class TimeZoneSheet extends StatefulWidget {
  const TimeZoneSheet({super.key});

  static Future<void> show(BuildContext context) {
    return TriftlyBottomSheet.show(context, child: const TimeZoneSheet());
  }

  @override
  State<TimeZoneSheet> createState() => _TimeZoneSheetState();
}

class _TimeZoneSheetState extends State<TimeZoneSheet> {
  String _homeId = 'hkt';
  String _awayId = 'jst';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _offsetLabel(TimeZoneOption zone) {
    final sign = zone.offsetHours >= 0 ? '+' : '';
    final hours = zone.offsetHours == zone.offsetHours.roundToDouble()
        ? zone.offsetHours.toInt().toString()
        : zone.offsetHours.toStringAsFixed(1);
    return 'UTC$sign$hours';
  }

  @override
  Widget build(BuildContext context) {
    final home = TimeZoneOptions.byId(_homeId);
    final away = TimeZoneOptions.byId(_awayId);
    final diffHours = away.offsetHours - home.offsetHours;
    final diffLabel = diffHours == 0
        ? 'Same time'
        : '${diffHours.abs().toStringAsFixed(diffHours == diffHours.roundToDouble() ? 0 : 1)}h ${diffHours > 0 ? 'ahead' : 'behind'}';

    return SheetScaffold(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionHeader(title: 'Time zones', caption: 'Home vs destination'),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ZoneSectionLabel(title: 'Home'),
                const SizedBox(height: AppSpacing.sm),
                _ZoneChipWrap(
                  selectedId: _homeId,
                  onSelected: (id) => setState(() => _homeId = id),
                ),
                const SheetSoftDivider(),
                const _ZoneSectionLabel(title: 'Destination'),
                const SizedBox(height: AppSpacing.sm),
                _ZoneChipWrap(
                  selectedId: _awayId,
                  onSelected: (id) => setState(() => _awayId = id),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SheetSectionHeader(title: 'Now'),
          const SizedBox(height: AppSpacing.md),
          SheetGradientHero(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: _ClockColumn(
                    zone: home,
                    formatTime: _formatTime,
                    offsetLabel: _offsetLabel(home),
                  ),
                ),
                Container(
                  width: 1,
                  height: 72,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _ClockColumn(
                    zone: away,
                    formatTime: _formatTime,
                    offsetLabel: _offsetLabel(away),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: SheetResultBanner(
              caption: 'Difference',
              text: diffLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneSectionLabel extends StatelessWidget {
  const _ZoneSectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
      ),
    );
  }
}

class _ZoneChipWrap extends StatelessWidget {
  const _ZoneChipWrap({
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: TimeZoneOptions.all.map((zone) {
        final selected = zone.id == selectedId;
        return Pressable(
          onTap: () => onSelected(zone.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1)
                  : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              zone.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ClockColumn extends StatelessWidget {
  const _ClockColumn({
    required this.zone,
    required this.formatTime,
    required this.offsetLabel,
  });

  final TimeZoneOption zone;
  final String Function(DateTime) formatTime;
  final String offsetLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = zone.now();

    return Column(
      children: [
        Text(
          zone.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatTime(now),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.05,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          offsetLabel,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
