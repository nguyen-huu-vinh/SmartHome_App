import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'app_icons.dart';
import 'badges.dart';
import 'pressable.dart';

/// Các tab của thanh điều hướng; [add] là nút hành động, không phải tab.
enum NavTab {
  home('Home'),
  rooms('Rooms'),
  add('Add device'),
  alerts('Notifications'),
  settings('Settings');

  const NavTab(this.label);
  final String label;
}

/// Thanh điều hướng dạng viên thuốc nổi ở đáy màn hình.
///
/// Đặt vào `Scaffold.bottomNavigationBar` với `extendBody: true`: nội dung
/// chạy dưới thanh, và `MediaQuery.paddingOf(context).bottom` của nội dung
/// đã gồm chiều cao thanh — dùng nó để chừa chỗ cuối danh sách cuộn.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.current,
    required this.onTap,
    this.badges = const {},
  });

  final NavTab current;
  final ValueChanged<NavTab> onTap;

  /// Số đếm trên icon (VD: số thông báo chưa xử lý).
  final Map<NavTab, int> badges;

  static const _button = 54.0;

  /// Lề dưới cho danh sách cuộn nằm sau thanh (thanh không che mục cuối).
  static double scrollPadding(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + 16;

  Widget _icon(NavTab tab) {
    final color = tab == current ? AppColors.dark : AppColors.idle;
    return switch (tab) {
      NavTab.home => HomeWifiIcon(
        size: 30,
        color: color,
        wifiColor: Colors.white,
      ),
      NavTab.rooms => const CubeIcon.grey(size: 26),
      NavTab.add => const Icon(Icons.add, color: AppColors.dark, size: 30),
      NavTab.alerts => Icon(
        Icons.notifications_rounded,
        size: 28,
        color: color,
      ),
      NavTab.settings => Icon(Icons.settings_rounded, size: 28, color: color),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        heightFactor: 1,
        // Giãn gần hết bề ngang, nhưng không quá rộng trên máy tính bảng.
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.line),
            boxShadow: AppShadows.floating,
          ),
          // Màn hẹp → nút tự co để đủ 5 nút trên 1 hàng.
          child: LayoutBuilder(
            builder: (_, box) {
              final size = (box.maxWidth / NavTab.values.length).clamp(
                40.0,
                _button,
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final tab in NavTab.values)
                    Tooltip(
                      message: tab.label,
                      child: Pressable(
                        onTap: () => onTap(tab),
                        haptic: true,
                        scale: 0.9,
                        selected: tab == NavTab.add ? null : tab == current,
                        borderRadius: BorderRadius.circular(size / 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tab == NavTab.add
                              ? AppColors.soft
                              : Colors.white,
                          // Tab đang chọn: nổi lên bằng bóng.
                          boxShadow: tab == current ? AppShadows.lifted : null,
                        ),
                        child: SizedBox.square(
                          dimension: size,
                          child: Center(
                            child: CountBadge(
                              count: badges[tab] ?? 0,
                              child: FittedBox(child: _icon(tab)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
