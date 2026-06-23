import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_zone_options.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';

class TimeZoneSheet extends StatefulWidget {
  const TimeZoneSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const TimeZoneSheet(),
    );
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
      title: 'Time zones',
      subtitle: 'Home vs destination',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ZonePicker(
            label: 'Home',
            value: _homeId,
            onChanged: (id) => setState(() => _homeId = id),
          ),
          const SizedBox(height: AppSpacing.md),
          _ZonePicker(
            label: 'Destination',
            value: _awayId,
            onChanged: (id) => setState(() => _awayId = id),
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

class _ZonePicker extends StatelessWidget {
  const _ZonePicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
            isDense: true,
          ),
          items: TimeZoneOptions.all
              .map((z) => DropdownMenuItem(value: z.id, child: Text('${z.label} (${z.city})')))
              .toList(),
          onChanged: (id) {
            if (id != null) onChanged(id);
          },
        ),
      ],
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
