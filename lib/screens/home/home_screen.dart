import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../data/app_state.dart';
import '../../l10n/l10n.dart';
import '../../widgets/app_tour.dart';
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

  /// Xem lại phần giới thiệu app (VD: từ tab Settings).
  static void replayTour(BuildContext context) =>
      context.findAncestorStateOfType<_HomeScreenState>()?._startTour();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _tab = NavTab.home;

  /// Tăng lên mỗi lần bấm Home → trang Home về trạng thái ban đầu.
  var _homeResets = 0;

  final _tourKeys = HomeTourKeys();
  final _navKeys = {
    NavTab.add: GlobalKey(debugLabel: 'tour: add'),
    NavTab.alerts: GlobalKey(debugLabel: 'tour: alerts'),
  };

  @override
  void initState() {
    super.initState();
    _firstTour();
  }

  /// Lần đầu vào app → tự mở phần giới thiệu.
  Future<void> _firstTour() async {
    if (await AppTour.seen() || !mounted) return;
    await _startTour();
  }

  /// Về tab Home ở trạng thái ban đầu, chờ màn hiện xong rồi giới thiệu.
  Future<void> _startTour() async {
    setState(() {
      _homeResets++;
      _tab = NavTab.home;
    });
    await Future<void>.delayed(const Duration(milliseconds: 800));
    // Trong lúc chờ đã mở màn khác → thôi, lần sau vào app sẽ giới thiệu.
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return;
    final l = context.l10n;
    await AppTour.show(context, [
      TourStep(
        target: _tourKeys.home,
        icon: Icons.home_rounded,
        // Ôm cả khối chọn nhà: dòng "Welcome Back" + tên nhà.
        also: [_tourKeys.homeLabel],
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: l.tourHomeTitle,
        message: l.tourHomeMessage,
      ),
      TourStep(
        target: _tourKeys.featured,
        icon: Icons.power_settings_new_rounded,
        title: l.tourFeaturedTitle,
        message: l.tourFeaturedMessage,
      ),
      TourStep(
        target: _navKeys[NavTab.add]!,
        icon: Icons.add_rounded,
        radius: 999,
        title: l.tourAddTitle,
        message: l.tourAddMessage,
      ),
      TourStep(
        target: _navKeys[NavTab.alerts]!,
        icon: Icons.notifications_rounded,
        radius: 999,
        title: l.tourAlertsTitle,
        message: l.tourAlertsMessage,
      ),
    ]);
  }

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
          badges: {NavTab.alerts: AppScope.of(context).alertCount},
          targets: _navKeys,
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
          HomeTab(resetToken: _homeResets, tour: _tourKeys),
          const RoomsTab(),
          const AlertsTab(),
          const SettingsTab(),
        ],
      ),
    );
  }
}
