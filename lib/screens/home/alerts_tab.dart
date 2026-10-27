import 'package:flutter/material.dart';

import '../../core/feedback.dart';
import '../../core/theme.dart';
import '../../data/activity_alert.dart';
import '../../data/app_state.dart';
import '../../data/home_device.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_image.dart';
import '../../widgets/device_controls.dart';
import '../../widgets/layout.dart';
import 'tab_page.dart';

/// Tab Activity Alerts: gợi ý tắt đèn, thiết bị mất kết nối / bị tắt.
/// Vuốt ngang để ẩn (có hoàn tác); Re-Connect thành công → thông báo biến mất.
class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  final _connecting = <ActivityAlert>{};

  static const _delays = [1, 2, 5, 10, 15, 30];
  var _delay = 1; // chỉ số trong [_delays] → 2 phút

  void _dismiss(ActivityAlert a) {
    final app = AppScope.read(context);
    final i = app.dismissAlert(a);
    if (i == null) return;
    context.toast(
      'Notification dismissed',
      action: 'Undo',
      onAction: () => app.restoreAlert(i, a),
    );
  }

  Future<void> _reconnect(ActivityAlert a) async {
    setState(() => _connecting.add(a));
    // TODO: thay bằng kết nối lại thật.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _connecting.remove(a));
    if (AppScope.read(context).dismissAlert(a) != null) {
      context.toast('Re-connected successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final alerts = app.alerts;
    return TabPage(
      title: 'Activity Alerts',
      children: [
        for (final a in alerts)
          Padding(
            key: ObjectKey(a),
            padding: const EdgeInsets.only(bottom: 16),
            child: Dismissible(
              key: ObjectKey(a),
              onDismissed: (_) => _dismiss(a),
              background: const _DismissBackground(Alignment.centerLeft),
              secondaryBackground: const _DismissBackground(
                Alignment.centerRight,
              ),
              child: a.kind == AlertKind.suggestion
                  ? _suggestion(app, a)
                  : _DeviceAlertCard(
                      alert: a,
                      busy: _connecting.contains(a),
                      onReconnect: () => _reconnect(a),
                    ),
            ),
          ),
        if (alerts.isEmpty)
          const EmptyState(
            icon: Icons.notifications_none_rounded,
            message: 'No notifications yet',
            padding: EdgeInsets.only(top: 80),
          ),
      ],
    );
  }

  /// Gợi ý tắt đèn: nút nguồn bật/tắt cả dãy đèn của phòng trong gợi ý.
  Widget _suggestion(AppState app, ActivityAlert a) {
    final lights = [
      for (final d in app.inRoom(a.room ?? ''))
        if (d.group == DeviceGroup.lights) d,
    ];
    return _SuggestionCard(
      alert: a,
      minutes: _delays[_delay],
      onMinutes: () => setState(() => _delay = (_delay + 1) % _delays.length),
      on: lights.any(app.isOn),
      onPower: (v) => app.setAllOn(lights, v),
    );
  }
}

/// Nền hiện ra khi vuốt để ẩn thông báo.
class _DismissBackground extends StatelessWidget {
  const _DismissBackground(this.alignment);

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: AppColors.grey),
    );
  }
}

/// Gợi ý tắt đèn: ảnh đèn có quầng ấm, giờ, câu hỏi, chọn thời gian + nút nguồn.
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.alert,
    required this.minutes,
    required this.onMinutes,
    required this.on,
    required this.onPower,
  });

  final ActivityAlert alert;
  final int minutes;
  final VoidCallback onMinutes;
  final bool on;
  final ValueChanged<bool> onPower;

  @override
  Widget build(BuildContext context) {
    // "11:30 PM" → số lớn + "PM" nhỏ.
    final parts = alert.title.split(' ');
    return AppCard(
      radius: AppSizes.radiusL,
      clip: true,
      child: Stack(
        children: [
          // Quầng sáng ấm dưới đèn, mờ đi khi tắt.
          Positioned(
            left: -60,
            top: 40,
            child: AnimatedOpacity(
              duration: AppMotion.medium,
              opacity: on ? 1 : 0,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x55F9C46B), Color(0x00F9C46B)],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    // Đèn treo chạm mép trên thẻ.
                    AppImage(alert.image, width: 92),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              alert.ago,
                              style: AppText.body(color: AppColors.grey),
                            ),
                            Text.rich(
                              TextSpan(
                                text: parts.first,
                                style: AppText.bold(30),
                                children: [
                                  if (parts.length > 1)
                                    TextSpan(
                                      text: ' ${parts.skip(1).join(' ')}',
                                      style: AppText.body(size: 18),
                                    ),
                                ],
                              ),
                            ),
                            Text(alert.message, style: AppText.body()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    spacing: 12,
                    children: [
                      // Màn hẹp → nhãn + ô phút tự thu nhỏ thay vì tràn.
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            spacing: 12,
                            children: [
                              Text(
                                'Turn Off After',
                                style: AppText.body(size: 16),
                              ),
                              AppCard(
                                radius: AppSizes.radiusS,
                                color: AppColors.surface,
                                shadow: null,
                                semanticLabel:
                                    'Turn off after $minutes minutes, change',
                                onTap: onMinutes,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                child: AnimatedSwitcher(
                                  duration: AppMotion.fast,
                                  child: Text(
                                    '$minutes Min',
                                    key: ValueKey(minutes),
                                    style: AppText.body(size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      PowerBox(on: on, onChanged: onPower),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thiết bị mất kết nối / bị tắt: ảnh, tiêu đề, mô tả, thời gian + Re-Connect.
class _DeviceAlertCard extends StatelessWidget {
  const _DeviceAlertCard({
    required this.alert,
    required this.busy,
    required this.onReconnect,
  });

  final ActivityAlert alert;
  final bool busy;
  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppSizes.radiusL,
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              AppImage(alert.image, width: 80, height: 80),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(alert.title, style: AppText.semibold(16)),
                    Text(
                      alert.message,
                      style: AppText.body(size: 16, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 16,
            children: [
              Text(alert.ago, style: AppText.body(color: AppColors.grey)),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: busy ? null : onReconnect,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      disabledBackgroundColor: AppColors.surface,
                      foregroundColor: AppColors.dark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        side: const BorderSide(color: AppColors.line),
                      ),
                    ),
                    child: busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Re-Connect',
                              maxLines: 1,
                              style: AppText.body(size: 16),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
