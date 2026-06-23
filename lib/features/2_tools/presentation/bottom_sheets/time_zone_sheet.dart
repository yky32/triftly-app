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
          _ZonePickerCard(
            label: 'Home',
            selectedId: _homeId,
            onSelected: (id) => setState(() => _homeId = id),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ZonePickerCard(
            label: 'Destination',
            selectedId: _awayId,
            onSelected: (id) => setState(() => _awayId = id),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _ClockCard(zone: home, formatTime: _formatTime, offsetLabel: _offsetLabel(home))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _ClockCard(zone: away, formatTime: _formatTime, offsetLabel: _offsetLabel(away))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.compare_arrows_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  diffLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZonePickerCard extends StatelessWidget {
  const _ZonePickerCard({
    required this.label,
    required this.selectedId,
    required this.onSelected,
  });

  final String label;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SheetSoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: TimeZoneOptions.all.map((zone) {
              final selected = zone.id == selectedId;
              return Pressable(
                onTap: () => onSelected(zone.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.1)
                        : (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    zone.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ClockCard extends StatelessWidget {
  const _ClockCard({
    required this.zone,
    required this.formatTime,
    required this.offsetLabel,
  });

  final TimeZoneOption zone;
  final String Function(DateTime) formatTime;
  final String offsetLabel;

  @override
  Widget build(BuildContext context) {
    final now = zone.now();

    return SheetSoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Text(zone.label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            formatTime(now),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(offsetLabel, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
