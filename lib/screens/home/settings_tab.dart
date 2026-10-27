import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/feedback.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/user.dart';
import '../../widgets/name_input_sheet.dart';
import '../auth/login_screen.dart';
import '../settings/legal_screen.dart';
import '../settings/profile_screen.dart';
import 'tab_page.dart';

/// Tab Settings: hồ sơ, các công tắc tuỳ chọn ([Preference]),
/// chia sẻ / đánh giá / góp ý, chính sách, điều khoản, đăng xuất.
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  static const _appLink = 'https://hoome.app';

  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _appLink));
    if (context.mounted) context.toast('App link copied to clipboard');
  }

  Future<void> _rate(BuildContext context) async {
    final stars = await showDialog<int>(
      context: context,
      builder: (_) => const _RateDialog(),
    );
    if (stars != null && context.mounted) {
      context.toast('Thanks for rating us $stars★');
    }
  }

  Future<void> _feedback(BuildContext context) async {
    final text = await showNameInputSheet(
      context,
      title: 'Send Feedback',
      hint: 'Your feedback',
      action: 'Send',
      capitalization: TextCapitalization.sentences,
      icon: const Icon(Icons.chat_rounded, color: AppColors.brand),
    );
    if (text != null && context.mounted) {
      context.toast('Thanks for your feedback!');
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await context.confirm(
      title: 'Log out?',
      message: 'You will need to log in again to control your home.',
      confirmLabel: 'Log out',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      riseRoute(const LoginScreen()),
      (_) => false,
    );
  }

  void _open(BuildContext context, Widget page) =>
      Navigator.push(context, smoothRoute(page));

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    Widget link(IconData icon, String label, VoidCallback onTap) =>
        _SettingsRow(
          icon: icon,
          label: label,
          onTap: onTap,
          trailing: const Icon(
            Icons.arrow_right_rounded,
            color: AppColors.grey,
          ),
        );

    return TabPage(
      title: 'Settings',
      children: [
        _SettingsGroup([
          _SettingsRow(
            icon: Icons.person_rounded,
            label: app.profile.name,
            onTap: () => _open(context, const ProfileScreen()),
            trailing: const Icon(Icons.edit_rounded, color: AppColors.dark),
          ),
        ]),
        _SettingsGroup([
          for (final p in Preference.values)
            _SettingsRow(
              icon: p.icon,
              label: p.label,
              onTap: () => app.setPref(p, !app.pref(p)),
              trailing: ExcludeSemantics(
                child: Switch(
                  value: app.pref(p),
                  onChanged: (v) => app.setPref(p, v),
                ),
              ),
              toggled: app.pref(p),
            ),
        ]),
        _SettingsGroup([
          link(Icons.share_rounded, 'Share this app', () => _share(context)),
          link(Icons.star_rounded, 'Rate Us', () => _rate(context)),
          link(Icons.chat_rounded, 'Send Feedback', () => _feedback(context)),
        ]),
        _SettingsGroup([
          link(
            Icons.verified_user_rounded,
            'Privacy Policy',
            () => _open(context, const LegalScreen(doc: LegalDoc.privacy)),
          ),
          link(
            Icons.edit_note_rounded,
            'Terms of Use',
            () => _open(context, const LegalScreen(doc: LegalDoc.terms)),
          ),
          link(Icons.logout_rounded, 'Logout', () => _logout(context)),
        ]),
      ],
    );
  }
}

/// Khối bo góc chứa các dòng, có đường kẻ giữa các dòng.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup(this.rows);

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusL);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppShadows.card,
        ),
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: AppColors.line),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                rows[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 1 dòng: icon, nhãn, phần đuôi (mũi tên / công tắc). Cả dòng bấm được.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.trailing,
    this.toggled,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget trailing;

  /// Dòng công tắc: trạng thái bật/tắt cho trình đọc màn hình.
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: toggled,
      button: toggled == null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              spacing: 16,
              children: [
                Icon(icon, color: AppColors.dark, size: 24),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(size: 16),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chọn 1–5 sao; Submit → trả về số sao.
class _RateDialog extends StatefulWidget {
  const _RateDialog();

  @override
  State<_RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<_RateDialog> {
  var _stars = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Us'),
      content: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                tooltip: plural(i, 'star'),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _stars = i);
                },
                icon: AnimatedScale(
                  scale: i <= _stars ? 1.1 : 1,
                  duration: AppMotion.fast,
                  child: Icon(
                    i <= _stars
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.amber,
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _stars == 0 ? null : () => Navigator.pop(context, _stars),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
