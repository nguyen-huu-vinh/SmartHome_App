import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/feedback.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../data/app_state.dart';
import '../../data/user.dart';
import '../../l10n/l10n.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/phone_field.dart';
import '../settings/legal_screen.dart';
import 'verify_screen.dart';

/// Tạo tài khoản: tên, số điện thoại, email, mật khẩu.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  late var _country = AppScope.read(context).profile.country;

  late final _fields = [_name, _phone, _email, _pass];
  late final _anyChange = Listenable.merge(_fields);

  // Chữ "Terms of Use" / "Privacy Policy" bấm được.
  late final _terms = TapGestureRecognizer()
    ..onTap = () => _openLegal(LegalDoc.terms);
  late final _privacy = TapGestureRecognizer()
    ..onTap = () => _openLegal(LegalDoc.privacy);

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      isValidPhone(_phone.text) &&
      isValidEmail(_email.text) &&
      _pass.text.isNotEmpty;

  @override
  void dispose() {
    for (final c in _fields) {
      c.dispose();
    }
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  void _openLegal(LegalDoc doc) =>
      Navigator.push(context, smoothRoute(LegalScreen(doc: doc)));

  // TODO: gọi API tạo tài khoản.
  void _continue() {
    final email = _email.text.trim();
    AppScope.read(context).updateProfile(
      Profile(
        name: _name.text.trim(),
        country: _country,
        phone: _phone.text.trim(),
        email: email,
      ),
    );
    Navigator.push(context, riseRoute(VerifyScreen(email: email)));
  }

  @override
  Widget build(BuildContext context) {
    final terms = AppText.body(color: AppColors.grey);
    final termsLink = AppText.link(color: AppColors.dark);
    return AuthLayout(
      fitContent: true,
      heroMaxFraction: 0.45,
      children: [
        AuthHeader(title: context.l10n.createAccount),
        const SizedBox(height: 12),
        AppTextField(
          controller: _name,
          hint: context.l10n.yourName,
          prefix: const Icon(Icons.person, color: AppColors.brand, size: 20),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
        ),
        const SizedBox(height: 12),
        PhoneField(
          controller: _phone,
          country: _country,
          onCountryChanged: (c) => setState(() => _country = c),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _email,
          hint: context.l10n.yourEmail,
          prefix: AppIcon.email.widget(20),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _pass,
          hint: context.l10n.createPassword,
          prefix: AppIcon.lock.widget(20),
          password: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          onSubmitted: (_) {
            if (_valid) _continue();
          },
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: _anyChange,
          builder: (_, _) => PrimaryButton(
            label: context.l10n.continueLabel,
            onPressed: _valid ? _continue : null,
          ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            text: context.l10n.agreePrefix,
            style: terms,
            children: [
              TextSpan(
                text: context.l10n.termsOfUse,
                style: termsLink,
                recognizer: _terms,
              ),
              TextSpan(text: context.l10n.agreeAnd),
              TextSpan(
                text: context.l10n.privacyPolicy,
                style: termsLink,
                recognizer: _privacy,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const OrDivider(),
        const SizedBox(height: 12),
        SocialRow(
          children: [
            SocialButton(
              tooltip: context.l10n.continueWithApple,
              icon: const Icon(Icons.apple, size: 28),
              onPressed: () => context.toast(context.l10n.signUpAppleSoon),
            ),
            SocialButton(
              tooltip: context.l10n.continueWithGoogle,
              icon: AppIcon.google.widget(28),
              onPressed: () => context.toast(context.l10n.signUpGoogleSoon),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AuthFooter(
          text: context.l10n.haveAccount,
          link: context.l10n.login,
          fontSize: 16,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
