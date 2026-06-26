import 'package:flutter/material.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/models/user.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/swipe_to_confirm.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/user_display_name_label.dart';

class UserDetailBottomSheet extends StatefulWidget {
  const UserDetailBottomSheet({required this.user, super.key});

  final User user;

  static Future<void> show(BuildContext context, {required User user}) {
    return TriftlyBottomSheet.show(
      context,
      child: UserDetailBottomSheet(user: user),
    );
  }

  @override
  State<UserDetailBottomSheet> createState() => _UserDetailBottomSheetState();
}

class _UserDetailBottomSheetState extends State<UserDetailBottomSheet> {
  final _nameController = TextEditingController();
  bool _editingDisplayName = false;
  bool _savingName = false;
  bool _signingOut = false;
  String? _error;
  int _swipeKey = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _resetSwipe() => setState(() => _swipeKey++);

  void _closeSheetSafely() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) navigator.pop();
    });
  }

  void _startEditingDisplayName(String currentName) {
    setState(() {
      _editingDisplayName = true;
      _error = null;
      _nameController.text = currentName;
    });
  }

  void _cancelEditingDisplayName() {
    setState(() {
      _editingDisplayName = false;
      _nameController.clear();
    });
  }

  bool get _canSaveDisplayName {
    final trimmed = _nameController.text.trim();
    return trimmed.isNotEmpty && !_savingName;
  }

  Future<void> _saveDisplayName(User user) async {
    final trimmed = _nameController.text.trim();
    if (trimmed.isEmpty || _savingName) return;
    if (trimmed == user.displayName) {
      _cancelEditingDisplayName();
      return;
    }

    setState(() {
      _savingName = true;
      _error = null;
    });

    try {
      await AppBootstrap.userSession.updateDisplayName(trimmed);
      if (!mounted) return;
      setState(() {
        _editingDisplayName = false;
        _savingName = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _savingName = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() {
      _signingOut = true;
      _error = null;
    });
    try {
      await AppBootstrap.userSession.signOut();
      if (!mounted) return;
      _closeSheetSafely();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _signingOut = false;
        _error = e.toString();
      });
      _resetSwipe();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = AppBootstrap.userSession;

    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final user = session.currentUser ?? widget.user;

        return SheetScaffold.swipeForm(
          compact: true,
          swipeKey: ValueKey(_swipeKey),
          swipeLabel: 'Slide to sign out',
          swipeStyle: SwipeToConfirmStyle.destructive,
          swipeEnabled: !_signingOut && !_editingDisplayName && !_savingName,
          onSwipeConfirmed: _signOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetSectionHeader(
                title: 'User details',
                caption: 'Your Triftly profile',
              ),
              const SizedBox(height: AppSpacing.md),
              SheetGradientHero(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    ProfileAvatar(user: user, isCloudSignedIn: true, radius: 40),
                    const SizedBox(height: AppSpacing.md),
                    UserDisplayNameLabel(
                      user: user,
                      textAlign: TextAlign.center,
                      iconSize: 20,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDark,
                          ),
                    ),
                if (user.email != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user.email!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
              const SizedBox(height: AppSpacing.md),
              if (_editingDisplayName)
                SheetSoftCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: SheetIconFieldRow(
                    icon: Icons.person_outline_rounded,
                    field: SheetInlineField(
                      controller: _nameController,
                      hint: 'Display name',
                      textInputAction: TextInputAction.done,
                      onChanged: () => setState(() {}),
                      onSubmitted: (_) => _saveDisplayName(user),
                    ),
                  ),
                )
              else
                SheetSoftCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _UserDetailRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Display name',
                        value: user.displayName,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: AppColors.primaryDark,
                          tooltip: 'Edit display name',
                          onPressed: () => _startEditingDisplayName(user.displayName),
                        ),
                      ),
                      const SheetSoftListDivider(),
                      _UserDetailRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email',
                        value: user.email ?? '—',
                      ),
                      const SheetSoftListDivider(),
                      _UserDetailRow(
                        icon: Icons.payments_outlined,
                        label: 'Default currency',
                        value: session.defaultCurrency,
                      ),
                    ],
                  ),
                ),
              if (_editingDisplayName) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: _savingName ? null : _cancelEditingDisplayName,
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _canSaveDisplayName ? () => _saveDisplayName(user) : null,
                      child: _savingName
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.error : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _UserDetailRow extends StatelessWidget {
  const _UserDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryDark),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
