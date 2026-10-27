import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/device.dart';
import '../../data/room.dart';
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
    final room = Room(name: name);
    AppScope.read(context).addRoom(room);
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

  /// Xong thiết lập → vào Home, không quay lại được các bước trước.
  void _finish() => Navigator.pushAndRemoveUntil(
    context,
    smoothRoute(const HomeScreen()),
    (_) => false,
  );

  @override
  Widget build(BuildContext context) {
    final rooms = AppScope.of(context).rooms;
    // Phòng đang chọn bị xoá ở nơi khác → về phòng đầu.
    final room = rooms.contains(_picked) ? _picked! : rooms.first;
    return LargeTitlePage(
      title: 'Manage Rooms & Devices',
      subtitle: 'Pick a room, then tick the devices that belong to it',
      // Nút + dòng "Add Now" ghim dưới đáy, nội dung phía trên cuộn.
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          PrimaryButton(
            label: 'Continue',
            onPressed: _assigned.isEmpty ? null : _finish,
          ),
          AuthFooter(
            text: 'Missed a device? ',
            link: 'Add Now',
            onTap: () =>
                Navigator.push(context, smoothRoute(const AddDevicesScreen())),
          ),
        ],
      ),
      children: [
        SectionHeader(
          'Select Room',
          trailing: LinkButton(
            label: 'Add Room',
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
        const SectionHeader('Assign devices'),
        const SizedBox(height: 16),
        if (widget.devices.isEmpty)
          const EmptyState(
            icon: Icons.devices_other_rounded,
            message: 'No connected devices yet.',
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        for (final d in widget.devices)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DeviceTile(
              device: d,
              // Thiết bị đang ở phòng khác → hiện tên phòng đó.
              status: switch (_assigned[d]) {
                final r? when r != room => 'Connected · ${r.name}',
                _ => 'Connected',
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
