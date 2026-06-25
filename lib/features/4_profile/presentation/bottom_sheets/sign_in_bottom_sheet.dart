import 'package:flutter/material.dart';
import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../../core/environment.dart';
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
      final profile = await session.signInWithEmail(email);
      if (!mounted) return;
      if (Environment.hasSupabase && profile == null) {
        setState(() {
          _awaitingCode = true;
          _submitting = false;
        });
        return;
      }
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      showCloseButton: false,
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
          const SizedBox(height: 12),
          if (!_awaitingCode)
            SheetSoftCard(
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: InputBorder.none,
                ),
              ),
            )
          else
            SheetSoftCard(
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Verification code',
                  border: InputBorder.none,
                ),
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          SheetPrimaryButton(
            label: _awaitingCode ? 'Verify' : 'Continue',
            onPressed: _submitting
                ? () {}
                : (_awaitingCode ? _verifyCode : _submitEmail),
          ),
        ],
      ),
    );
  }
}
