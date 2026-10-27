import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../data/app_state.dart';
import '../../widgets/fade_indexed_stack.dart';
import '../../widgets/floating_nav_bar.dart';
import '../setup/add_devices_screen.dart';
import 'alerts_tab.dart';
import 'home_tab.dart';
import 'rooms_tab.dart';
import 'settings_tab.dart';

/// Màn chính sau khi đăng nhập: 4 tab (Home, Rooms, Alerts, Settings)
/// + thanh điều hướng nổi; nút "+" mở màn thêm thiết bị.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _tab = NavTab.home;

  /// Tăng lên mỗi lần bấm Home → trang Home về trạng thái ban đầu.
  var _homeResets = 0;

  void _onNav(NavTab tab) {
    if (tab == NavTab.add) {
      Navigator.push(context, smoothRoute(const AddDevicesScreen()));
      return;
    }
    setState(() {
      if (tab == NavTab.home) _homeResets++;
      _tab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nội dung chạy dưới thanh điều hướng nổi.
      extendBody: true,
      bottomNavigationBar: Builder(
        // Chỉ thanh điều hướng vẽ lại khi số thông báo đổi.
        builder: (context) => FloatingNavBar(
          current: _tab,
          onTap: _onNav,
          badges: {NavTab.alerts: AppScope.of(context).alerts.length},
        ),
      ),
      // Giữ nguyên trạng thái từng tab (vị trí cuộn, ô tìm kiếm).
      body: FadeIndexedStack(
        index: switch (_tab) {
          NavTab.home || NavTab.add => 0,
          NavTab.rooms => 1,
          NavTab.alerts => 2,
          NavTab.settings => 3,
        },
        children: [
          HomeTab(resetToken: _homeResets),
          const RoomsTab(),
          const AlertsTab(),
          const SettingsTab(),
        ],
      ),
    );
  }
}
