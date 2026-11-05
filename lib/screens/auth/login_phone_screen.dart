import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/feedback.dart';
import '../../core/routes.dart';
import '../../core/validators.dart';
import '../../data/app_state.dart';
import '../../l10n/l10n.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/phone_field.dart';
import '../setup/manage_homes_screen.dart';
import 'signup_screen.dart';

/// Đăng nhập bằng số điện thoại.
class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final _phone = TextEditingController();
  late var _country = AppScope.read(context).profile.country;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  // TODO: gửi mã OTP qua SMS.
  void _continue() {
    final app = AppScope.read(context);
    app.updateProfile(
      app.profile.copyWith(country: _country, phone: _phone.text.trim()),
    );
    Navigator.push(context, riseRoute(const ManageHomesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      heroMaxFraction: 0.36,
      children: [
        AuthHeader(title: context.l10n.welcomeBack),
        const SizedBox(height: 24),
        PhoneField(
          controller: _phone,
          country: _country,
          onCountryChanged: (c) => setState(() => _country = c),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: _phone,
          builder: (_, _) => PrimaryButton(
            label: context.l10n.continueLabel,
            onPressed: isValidPhone(_phone.text) ? _continue : null,
          ),
        ),
        const SizedBox(height: 16),
        const OrDivider(),
        const SizedBox(height: 16),
        SocialRow(
          children: [
            SocialButton(
              tooltip: context.l10n.continueWithApple,
              icon: const Icon(Icons.apple, size: 28),
              onPressed: () => context.toast(context.l10n.signInAppleSoon),
            ),
            SocialButton(
              tooltip: context.l10n.continueWithGoogle,
              icon: AppIcon.google.widget(28),
              onPressed: () => context.toast(context.l10n.signInGoogleSoon),
            ),
            // Quay lại màn đăng nhập bằng email.
            SocialButton(
              tooltip: context.l10n.continueWithEmail,
              icon: const Icon(Icons.email_rounded, size: 26),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AuthFooter(
          text: context.l10n.noAccount,
          link: context.l10n.createAccount,
          onTap: () => Navigator.push(context, riseRoute(const SignupScreen())),
        ),
      ],
    );
  }
}
