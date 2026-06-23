import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/triftly_app_bar_title.dart';
import '../../../../core/widgets/triftly_motion.dart';
import '../bottom_sheets/currency_converter_sheet.dart';
import '../bottom_sheets/mapcode_finder_sheet.dart';
import '../bottom_sheets/time_zone_sheet.dart';
import '../bottom_sheets/units_converter_sheet.dart';

enum TravelToolId {
  packing,
  currency,
  timeZone,
  units,
  mapcode,
  weather,
  phraseBook,
  documents,
  tipCalculator,
}

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  static const _liveTools = {
    TravelToolId.currency,
    TravelToolId.units,
    TravelToolId.timeZone,
    TravelToolId.mapcode,
  };

  static bool isLive(TravelToolId id) => _liveTools.contains(id);

  static const _kits = [
    _TravelKit(
      emoji: '✈️',
      title: 'Long-haul flight',
      subtitle: 'Neck pillow, charger, docs, snacks',
      tint: Color(0xFF0369A1),
    ),
    _TravelKit(
      emoji: '🏖️',
      title: 'Beach weekend',
      subtitle: 'Sunscreen, sandals, dry bag, shades',
      tint: Color(0xFF0D9488),
    ),
    _TravelKit(
      emoji: '🏙️',
      title: 'City break',
      subtitle: 'Comfort shoes, power bank, transit card',
      tint: Color(0xFF7C3AED),
    ),
    _TravelKit(
      emoji: '🏔️',
      title: 'Cold weather',
      subtitle: 'Layers, lip balm, hand warmers, thermos',
      tint: Color(0xFF64748B),
    ),
  ];

  static const _essentials = [
    _TravelTool(
      id: TravelToolId.packing,
      icon: Icons.checklist_rounded,
      title: 'Packing list',
      subtitle: 'Reusable checklists per trip',
      tint: Color(0xFF0D9488),
    ),
    _TravelTool(
      id: TravelToolId.currency,
      icon: Icons.currency_exchange_rounded,
      title: 'Currency',
      subtitle: 'Quick convert on the go',
      tint: Color(0xFF0369A1),
    ),
    _TravelTool(
      id: TravelToolId.timeZone,
      icon: Icons.schedule_rounded,
      title: 'Time zones',
      subtitle: 'Home vs local clock',
      tint: Color(0xFF7C3AED),
    ),
    _TravelTool(
      id: TravelToolId.units,
      icon: Icons.straighten_rounded,
      title: 'Units',
      subtitle: 'km, °C, kg conversions',
      tint: Color(0xFF64748B),
    ),
  ];

  static const _japan = [
    _TravelTool(
      id: TravelToolId.mapcode,
      icon: Icons.pin_drop_outlined,
      title: 'Mapcode',
      subtitle: 'Japan nav codes finder',
      tint: Color(0xFFBE123C),
    ),
  ];

  static const _more = [
    _TravelTool(
      id: TravelToolId.weather,
      icon: Icons.cloud_outlined,
      title: 'Weather',
      subtitle: 'Forecast for your destination',
      tint: Color(0xFF0284C7),
    ),
    _TravelTool(
      id: TravelToolId.phraseBook,
      icon: Icons.translate_rounded,
      title: 'Phrase book',
      subtitle: 'Common phrases offline',
      tint: Color(0xFFDB2777),
    ),
    _TravelTool(
      id: TravelToolId.documents,
      icon: Icons.folder_open_rounded,
      title: 'Documents',
      subtitle: 'Passport, visa, insurance',
      tint: Color(0xFFC2410C),
    ),
    _TravelTool(
      id: TravelToolId.tipCalculator,
      icon: Icons.calculate_outlined,
      title: 'Tip calculator',
      subtitle: 'Split bills fairly',
      tint: Color(0xFF059669),
    ),
  ];

  static void openTool(BuildContext context, TravelToolId id) {
    if (!isLive(id)) return;

    switch (id) {
      case TravelToolId.currency:
        CurrencyConverterSheet.show(context);
      case TravelToolId.units:
        UnitsConverterSheet.show(context);
      case TravelToolId.timeZone:
        TimeZoneSheet.show(context);
      case TravelToolId.mapcode:
        MapcodeFinderSheet.show(context);
      case TravelToolId.packing:
      case TravelToolId.weather:
      case TravelToolId.phraseBook:
      case TravelToolId.documents:
      case TravelToolId.tipCalculator:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const TriftlyAppBarTitle(title: 'Tools')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.listBottomInset(context),
        ),
        children: [
          const SectionHeader(title: 'Travel kits'),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kits.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) => _KitCard(kit: _kits[index]),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Essentials'),
          _ToolGrid(tools: _essentials),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Japan'),
          _ToolGrid(tools: _japan),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'More'),
          _ToolGrid(tools: _more),
        ],
      ),
    );
  }
}

class _TravelKit {
  const _TravelKit({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.tint,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color tint;
}

class _TravelTool {
  const _TravelTool({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
  });

  final TravelToolId id;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;

  bool get isLive => ToolsPage.isLive(id);
}

class _ToolGrid extends StatelessWidget {
  const _ToolGrid({required this.tools});

  final List<_TravelTool> tools;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) => _ToolTile(tool: tools[index]),
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Text(
        'Soon',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _KitCard extends StatelessWidget {
  const _KitCard({required this.kit});

  final _TravelKit kit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _DimmedWhenDisabled(
      enabled: false,
      child: Pressable(
        onTap: null,
        child: SizedBox(
          width: 168,
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kit.tint.withValues(alpha: isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  alignment: Alignment.center,
                  child: Text(kit.emoji, style: const TextStyle(fontSize: 22)),
                ),
                const Spacer(),
                Text(
                  kit.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  kit.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool});

  final _TravelTool tool;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = tool.isLive;

    return _DimmedWhenDisabled(
      enabled: enabled,
      child: Pressable(
        onTap: enabled ? () => ToolsPage.openTool(context, tool.id) : null,
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tool.tint.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(tool.icon, size: 20, color: tool.tint),
              ),
              const Spacer(),
              Text(
                tool.title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                tool.subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DimmedWhenDisabled extends StatelessWidget {
  const _DimmedWhenDisabled({
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.38,
          child: child,
        ),
        if (!enabled)
          const Positioned(
            top: 6,
            right: 6,
            child: _SoonBadge(),
          ),
      ],
    );
  }
}
