import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/feedback.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../data/app_state.dart';
import '../../data/auth_service.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_layout.dart';
import '../setup/manage_homes_screen.dart';
import 'login_phone_screen.dart';
import 'signup_screen.dart';

/// Đăng nhập bằng email + mật khẩu (hoặc chuyển sang số điện thoại).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final _anyChange = Listenable.merge([_email, _password]);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _valid => isValidEmail(_email.text) && _password.text.isNotEmpty;

  // TODO: gọi API đăng nhập.
  void _continue() {
    final app = AppScope.read(context);
    app.updateProfile(app.profile.copyWith(email: _email.text.trim()));
    Navigator.push(context, riseRoute(const ManageHomesScreen()));
  }

  Future<void> _googleSignIn() async {
    try {
      final token = await signInWithGoogle();
      if (!mounted) return;
      if (token == null) {
        context.toast('Google sign-in failed');
        return;
      }
      Navigator.push(context, riseRoute(const ManageHomesScreen()));
    } catch (_) {
      if (mounted) context.toast('Google sign-in failed');
    }
  }

  void _forgotPassword() {
    final email = _email.text.trim();
    context.toast(
      isValidEmail(email)
          ? 'Password reset link sent to $email'
          : 'Enter your email above to reset your password',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      // Ảnh thấp hơn chút để màn 812px thấy đủ tới dòng "Create Account".
      heroMaxFraction: 0.36,
      children: [
        const AuthHeader(title: 'Welcome Back'),
        const SizedBox(height: 24),
        AppTextField(
          controller: _email,
          hint: 'Email',
          prefix: AppIcon.email.widget(20),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _password,
          hint: 'Password',
          prefix: AppIcon.lock.widget(20),
          password: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) {
            if (_valid) _continue();
          },
        ),
        const SizedBox(height: 4),
        LinkButton(
          label: 'Forgot Password?',
          style: AppText.link(color: AppColors.grey),
          onTap: _forgotPassword,
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: _anyChange,
          builder: (_, _) => PrimaryButton(
            label: 'Continue',
            onPressed: _valid ? _continue : null,
          ),
        ),
        const SizedBox(height: 16),
        const OrDivider(),
        const SizedBox(height: 16),
        SocialRow(
          children: [
            SocialButton(
              tooltip: 'Continue with Apple',
              icon: const Icon(Icons.apple, size: 28),
              onPressed: () =>
                  context.toast('Sign in with Apple is coming soon'),
            ),
            SocialButton(
              tooltip: 'Continue with Google',
              icon: AppIcon.google.widget(28),
              onPressed: _googleSignIn,
            ),
            SocialButton(
              tooltip: 'Continue with phone number',
              icon: AppIcon.phone.widget(28),
              onPressed: () =>
                  Navigator.push(context, riseRoute(const LoginPhoneScreen())),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AuthFooter(
          text: 'Don’t have an account? ',
          link: 'Create Account',
          onTap: () => Navigator.push(context, riseRoute(const SignupScreen())),
        ),
      ],
    );
  }
}
