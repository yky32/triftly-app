import 'package:flutter/material.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/environment.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheet_form_primitives.dart';
import '../../../../core/widgets/sheet_scaffold.dart';
import '../../../../core/widgets/triftly_bottom_sheet.dart';

class SignInBottomSheet extends StatefulWidget {
  const SignInBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return TriftlyBottomSheet.show(context, child: const SignInBottomSheet());
  }

  @override
  State<SignInBottomSheet> createState() => _SignInBottomSheetState();
}

class _SignInBottomSheetState extends State<SignInBottomSheet> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _awaitingCode = false;
  bool _submitting = false;
  String? _error;
  int _swipeKey = 0;

  bool get _canSubmit {
    if (_submitting) return false;
    if (_awaitingCode) return _codeController.text.trim().isNotEmpty;
    return _emailController.text.trim().isNotEmpty;
  }

  void _onFieldChanged() {
    setState(() {
      if (_error != null) _error = null;
    });
  }

  void _resetSwipe() => setState(() => _swipeKey++);

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final session = AppBootstrap.userSession;
      final user = await session.signInWithEmail(email);
      if (!mounted) return;
      if (Environment.hasSupabase && user == null) {
        setState(() {
          _awaitingCode = true;
          _submitting = false;
        });
        _resetSwipe();
        return;
      }
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
      _resetSwipe();
    }
  }

  Future<void> _verifyCode() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (email.isEmpty || code.isEmpty || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AppBootstrap.userSession.verifyEmailOtp(email: email, token: code);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
      _resetSwipe();
    }
  }

  void _onConfirmed() {
    if (_awaitingCode) {
      _verifyCode();
    } else {
      _submitEmail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SheetScaffold.swipeForm(
      swipeKey: ValueKey(_swipeKey),
      swipeLabel: _awaitingCode ? 'Slide to verify' : 'Slide to sign in',
      swipeEnabled: _canSubmit,
      onSwipeConfirmed: _onConfirmed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetSectionHeader(
            title: _awaitingCode ? 'Check your email' : 'Sign in',
            caption: _awaitingCode
                ? 'Enter the code we sent you'
                : Environment.hasSupabase
                    ? 'Magic link or one-time code'
                    : 'Local guest session for now',
          ),
          const SizedBox(height: AppSpacing.md),
          SheetSoftCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: SheetIconFieldRow(
              icon: _awaitingCode ? Icons.pin_outlined : Icons.mail_outline_rounded,
              field: SheetInlineField(
                controller: _awaitingCode ? _codeController : _emailController,
                hint: _awaitingCode ? 'Verification code' : 'Email address',
                keyboardType: _awaitingCode
                    ? TextInputType.number
                    : TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onChanged: _onFieldChanged,
              ),
            ),
          ),
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
  }
}
