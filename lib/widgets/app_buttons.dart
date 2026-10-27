import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'pressable.dart';

final _shape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(AppSizes.radiusM),
);

/// Nút chính màu tối. [onPressed] = null → nút xám (disabled).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.dark,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.dark,
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        shape: _shape,
      ),
      child: Text(label, style: AppText.button),
    );
  }
}

/// Nút viền màu brand, nền trắng.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.brand,
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        side: const BorderSide(color: AppColors.brand),
        shape: _shape,
      ),
      child: Text(
        label,
        style: AppText.button.copyWith(color: AppColors.brand),
      ),
    );
  }
}

/// Nút nền xám nhạt, chữ tối (VD: Stop Scanning).
class GreyButton extends StatelessWidget {
  const GreyButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.field,
        foregroundColor: AppColors.dark,
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        side: const BorderSide(color: AppColors.line),
        shape: _shape,
      ),
      child: Text(label, style: AppText.button.copyWith(color: AppColors.dark)),
    );
  }
}

/// Nút đăng nhập mạng xã hội (Apple, Google, ...).
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Widget icon;

  /// Tên nút cho trình đọc màn hình, VD: "Continue with Google".
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.field,
          foregroundColor: AppColors.dark,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          side: const BorderSide(color: AppColors.border),
          shape: _shape,
        ),
        child: icon,
      ),
    );
  }
}

/// Hàng nút chia đều chiều ngang.
class SocialRow extends StatelessWidget {
  const SocialRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [for (final c in children) Expanded(child: c)],
    );
  }
}

/// Nút quay lại tròn, nền trắng.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Back',
      child: Pressable(
        onTap: () => Navigator.maybePop(context),
        scale: 0.9,
        borderRadius: BorderRadius.circular(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: const SizedBox.square(
          dimension: 38,
          child: Icon(Icons.arrow_left, size: 28, color: AppColors.dark),
        ),
      ),
    );
  }
}

/// Chữ bấm được (VD: "View all", "Add Room ⊕"), vùng bấm cao hơn chữ.
class LinkButton extends StatelessWidget {
  const LinkButton({
    super.key,
    required this.label,
    required this.onTap,
    this.style,
    this.trailing,
  });

  final String label;
  final VoidCallback onTap;

  /// Mặc định: chữ xám cỡ 16.
  final TextStyle? style;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      ripple: false,
      scale: 0.95,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text(
            label,
            style: style ?? AppText.body(size: 16, color: AppColors.grey),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// ───── Or ─────
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Text('Or', style: AppText.body(color: AppColors.grey)),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
