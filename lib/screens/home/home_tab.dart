import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/home_device.dart';
import '../../data/room.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/device_cards.dart';
import '../../widgets/device_sheet/device_sheet.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/home_switcher_header.dart';
import '../../widgets/layout.dart';
import '../../widgets/manage_homes_sheet.dart';
import '../../widgets/room_cards.dart';
import '../../widgets/search_box.dart';
import 'device_list_screen.dart';

/// Tab Home: chọn nhà, tìm / lọc theo phòng, thẻ nổi bật,
/// các nhóm thiết bị cuộn ngang.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.resetToken});

  /// Đổi giá trị → về trạng thái ban đầu: bỏ tìm kiếm, bỏ lọc phòng,
  /// thẻ nổi bật về trang đầu, cuộn lên đầu.
  final int resetToken;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _query = '';

  /// Phòng đang lọc (null = tất cả).
  Room? _room;
  int _page = 0;
  final _pager = PageController();
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(HomeTab old) {
    super.didUpdateWidget(old);
    if (old.resetToken != widget.resetToken) _reset();
  }

  @override
  void dispose() {
    _pager.dispose();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    _search.clear();
    _query = '';
    _room = null;
    _resetPage();
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: AppMotion.slow, curve: AppMotion.curve);
    }
  }

  /// Danh sách thẻ nổi bật đổi → về trang đầu.
  void _resetPage() {
    _page = 0;
    if (_pager.hasClients) _pager.jumpToPage(0);
  }

  /// Bảng quản lý nhà; bấm Continue → áp dụng.
  Future<void> _manageHomes() async {
    final app = AppScope.read(context);
    final r = await showManageHomesSheet(
      context,
      homes: app.homes,
      index: app.homeIndex,
    );
    if (r != null) app.setHomes(r.homes, index: r.index);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    // Phòng đang lọc vừa bị xoá → bỏ lọc.
    final room = app.rooms.contains(_room) ? _room : null;
    final q = _query.trim().toLowerCase();
    final visible = [
      for (final d in app.devices)
        if ((room == null || d.room == room.name) &&
            d.name.toLowerCase().contains(q))
          d,
    ];
    final featured = [
      for (final d in visible)
        if (d.switchable) d,
    ];
    return Column(
      children: [
        HomeSwitcherHeader(
          homes: app.homes,
          index: app.homeIndex,
          onTap: _manageHomes,
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              top: 16,
              bottom: FloatingNavBar.scrollPadding(context),
            ),
            children: [
              _pad(
                SearchBox(
                  controller: _search,
                  hint: 'Search Devices',
                  onChanged: (v) => setState(() {
                    _query = v;
                    _resetPage();
                  }),
                ),
              ),
              const SizedBox(height: 16),
              HorizontalList(
                height: AppSizes.scaled(context, 58),
                itemCount: app.rooms.length,
                itemBuilder: (_, i) {
                  final r = app.rooms[i];
                  return RoomChip(
                    room: r,
                    count: app.countIn(r),
                    selected: r == room,
                    // Bấm lại phòng đang chọn → bỏ lọc.
                    onTap: () => setState(() {
                      _room = r == room ? null : r;
                      _resetPage();
                    }),
                  );
                },
              ),
              if (featured.isNotEmpty) ...[
                const SizedBox(height: 16),
                _featured(app, featured),
              ],
              for (final g in DeviceGroup.values)
                ..._group(g, [
                  for (final d in visible)
                    if (d.group == g) d,
                ]),
              if (visible.isEmpty)
                const EmptyState(
                  icon: Icons.search_off_rounded,
                  message: 'No devices found',
                ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _pad(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
    child: child,
  );

  Widget _featured(AppState app, List<HomeDevice> items) {
    final page = _page.clamp(0, items.length - 1);
    return Column(
      children: [
        SizedBox(
          height: AppSizes.scaled(context, 200),
          child: PageView.builder(
            controller: _pager,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final d = items[i];
              return _pad(
                FeaturedCard(
                  device: d,
                  on: app.isOn(d),
                  onChanged: (v) => app.setOn(d, v),
                  onTap: () => showDeviceSheet(context, d),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _PageDots(count: items.length, index: page),
      ],
    );
  }

  List<Widget> _group(DeviceGroup g, List<HomeDevice> items) {
    if (items.isEmpty) return const [];
    return [
      const SizedBox(height: 18),
      _pad(
        SectionHeader(
          g.title,
          trailing: LinkButton(
            label: 'View all',
            onTap: () => Navigator.push(
              context,
              smoothRoute(DeviceListScreen(group: g)),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      HorizontalList(
        height: AppSizes.scaled(context, deviceCardHeight(g)),
        itemCount: items.length,
        itemBuilder: (_, i) => DeviceCard(device: items[i]),
      ),
    ];
  }
}

/// Chỉ báo trang: đường mảnh, trang hiện tại là viên tối trượt theo.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    const width = 100.0, pill = 28.0;
    final x = count <= 1 ? 0.0 : index / (count - 1) * (width - pill);
    return Semantics(
      label: 'Page ${index + 1} of $count',
      child: SizedBox(
        width: width,
        height: 8,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(height: 2, color: AppColors.muted),
            AnimatedPositioned(
              duration: AppMotion.medium,
              curve: AppMotion.curve,
              left: x,
              child: Container(
                width: pill,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
