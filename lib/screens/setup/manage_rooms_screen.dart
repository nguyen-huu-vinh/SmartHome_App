import 'package:flutter/material.dart';

import '../../core/feedback.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/device.dart';
import '../../data/home_api.dart';
import '../../data/home_device.dart';
import '../../data/room.dart';
import '../../l10n/l10n.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/badges.dart';
import '../../widgets/large_title_page.dart';
import '../../widgets/layout.dart';
import '../../widgets/list_card.dart';
import '../../widgets/name_input_sheet.dart';
import '../../widgets/room_cards.dart';
import '../home/home_screen.dart';
import 'add_devices_screen.dart';

/// Chọn phòng rồi tích các thiết bị thuộc phòng đó.
/// Mỗi thiết bị chỉ thuộc 1 phòng: tích ở phòng mới sẽ gỡ khỏi phòng cũ.
class ManageRoomsScreen extends StatefulWidget {
  const ManageRoomsScreen({super.key, required this.devices});

  final List<Device> devices;

  @override
  State<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  Room? _picked;
  final _roomScroll = ScrollController();

  /// Thiết bị → phòng được gán.
  final _assigned = <Device, Room>{};

  @override
  void dispose() {
    _roomScroll.dispose();
    super.dispose();
  }

  void _toggle(Device d, Room room) => setState(() {
    if (_assigned[d] == room) {
      _assigned.remove(d);
    } else {
      _assigned[d] = room;
    }
  });

  Future<void> _addRoom() async {
    final name = await showAddRoomSheet(context);
    if (name == null || !mounted) return;
    final app = AppScope.read(context);
    if (app.hasRoom(name)) return context.toast(context.l10n.roomExists(name));
    final room = Room(name: name);
    app.addRoom(room);
    setState(() => _picked = room);
    // Phòng mới nằm cuối danh sách ngang → cuộn tới cho thấy.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_roomScroll.hasClients) return;
      _roomScroll.animateTo(
        _roomScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: AppMotion.curve,
      );
    });
  }

  var _saving = false;

  /// Lưu các thiết bị vào nhà (đúng phòng đã gán) → vào Home, không quay lại
  /// được các bước trước. Server lỗi → ở lại để bấm Continue thử lại.
  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await AppScope.read(context).addDevices([
        for (final MapEntry(key: d, value: room) in _assigned.entries)
          HomeDevice(
            name: d.name,
            image: d.image,
            group: d.group,
            room: room.name,
          ),
      ]);
    } on ApiException {
      if (!mounted) return;
      setState(() => _saving = false);
      context.toast(context.l10n.couldntAddDevices);
      return;
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      smoothRoute(const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = AppScope.of(context).rooms;
    // Phòng đang chọn bị xoá ở nơi khác → về phòng đầu.
    final room = rooms.contains(_picked) ? _picked! : rooms.first;
    return LargeTitlePage(
      title: context.l10n.manageRoomsTitle,
      subtitle: context.l10n.manageRoomsSubtitle,
      // Nút + dòng "Add Now" ghim dưới đáy, nội dung phía trên cuộn.
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          PrimaryButton(
            label: context.l10n.continueLabel,
            onPressed: _assigned.isEmpty || _saving ? null : _finish,
          ),
          AuthFooter(
            text: context.l10n.missedDevice,
            link: context.l10n.addNow,
            onTap: () =>
                Navigator.push(context, smoothRoute(const AddDevicesScreen())),
          ),
        ],
      ),
      children: [
        SectionHeader(
          context.l10n.selectRoom,
          trailing: LinkButton(
            label: context.l10n.addRoom,
            style: AppText.medium(16),
            trailing: const AddBadge(),
            onTap: _addRoom,
          ),
        ),
        const SizedBox(height: 10),
        // Kéo ngang tràn ra mép phải màn hình như thiết kế.
        HorizontalList(
          controller: _roomScroll,
          height: AppSizes.scaled(context, 86),
          padding: EdgeInsets.zero,
          itemCount: rooms.length,
          itemBuilder: (_, i) => RoomCard(
            room: rooms[i],
            selected: rooms[i] == room,
            onTap: () => setState(() => _picked = rooms[i]),
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(context.l10n.assignDevices),
        const SizedBox(height: 16),
        if (widget.devices.isEmpty)
          EmptyState(
            icon: Icons.devices_other_rounded,
            message: context.l10n.noConnectedDevices,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        for (final d in widget.devices)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DeviceTile(
              device: d,
              // Thiết bị đang ở phòng khác → hiện tên phòng đó.
              status: switch (_assigned[d]) {
                final r? when r != room => context.l10n.connectedInRoom(r.name),
                _ => context.l10n.connected,
              },
              selected: _assigned[d] == room,
              onTap: () => _toggle(d, room),
              trailing: AnimatedScale(
                scale: _assigned[d] == room ? 1 : 0,
                duration: AppMotion.fast,
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.dark,
                  child: Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
