import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/feedback.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/pressable.dart';
import '../setup/manage_homes_screen.dart';

/// Nhập mã 6 số đã gửi tới [email]; hết giờ chờ mới được gửi lại mã.
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  static const _wait = 72; // giây chờ trước khi được gửi lại mã
  static const _codeLength = 6;

  final _code = TextEditingController();
  int _left = _wait;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _left = _wait;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) t.cancel();
      setState(() => _left--);
    });
  }

  // TODO: gọi API gửi lại mã.
  void _resend() {
    setState(_startTimer);
    context.toast('A new code has been sent to your email');
  }

  // TODO: gọi API kiểm tra mã.
  void _continue() =>
      Navigator.push(context, riseRoute(const ManageHomesScreen()));

  String get _time =>
      '${(_left ~/ 60).toString().padLeft(2, '0')}:'
      '${(_left % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final canResend = _left == 0;
    return AuthLayout(
      heroMaxFraction: 0.375,
      children: [
        AuthHeader(
          title: 'Verify That’s You',
          subtitle: 'We just sent a 6-digit verification code to your email ',
          subtitleExtra: [
            TextSpan(
              text: maskEmail(widget.email),
              style: AppText.link(size: 16, color: AppColors.dark),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppTextField(
          controller: _code,
          hint: 'Enter Code',
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: _codeLength,
          letterSpacing: 4,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Pressable(
              onTap: canResend ? _resend : null,
              ripple: false,
              scale: 0.95,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Resend Code',
                style: AppText.link(
                  size: 16,
                  color: canResend ? AppColors.dark : AppColors.grey,
                ),
              ),
            ),
            if (!canResend)
              Text(
                _time,
                style: AppText.body(size: 16, color: AppColors.brand),
              ),
          ],
        ),
        const SizedBox(height: 18),
        ListenableBuilder(
          listenable: _code,
          builder: (_, _) => PrimaryButton(
            label: 'Continue',
            onPressed: _code.text.length == _codeLength ? _continue : null,
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: LinkButton(
            label: 'Change email?',
            style: AppText.link(size: 16, color: AppColors.grey),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
