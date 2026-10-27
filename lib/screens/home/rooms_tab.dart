import 'package:flutter/material.dart';

import '../../core/feedback.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/room.dart';
import '../../widgets/app_card.dart';
import '../../widgets/badges.dart';
import '../../widgets/dashed_box.dart';
import '../../widgets/manage_room_sheet.dart';
import '../../widgets/name_input_sheet.dart';
import '../setup/add_devices_screen.dart';
import 'room_details_screen.dart';
import 'tab_page.dart';

/// Tab Rooms: các phòng trong nhà + số thiết bị. Bấm phòng → bảng
/// Manage Room, Continue → màn chi tiết phòng. "Manage" → chế độ sửa:
/// xoá phòng (có hoàn tác), thêm phòng mới.
class RoomsTab extends StatefulWidget {
  const RoomsTab({super.key});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  static const _tileHeight = 124.0;

  var _editing = false;

  void _remove(Room room) {
    final app = AppScope.read(context);
    final i = app.removeRoom(room);
    if (i == null) return;
    context.toast(
      '${room.name} removed',
      action: 'Undo',
      onAction: () => app.insertRoom(i, room),
    );
  }

  /// Bảng Manage Room: chọn phòng / thêm thiết bị; Continue → mở phòng đó.
  Future<void> _open(Room room) async {
    final picked = await showManageRoomSheet(
      context,
      initial: room,
      onAddDevice: (_) =>
          Navigator.push(context, smoothRoute(const AddDevicesScreen())),
    );
    if (picked == null || !mounted) return;
    Navigator.push(context, smoothRoute(RoomDetailsScreen(room: picked)));
  }

  Future<void> _add() async {
    final name = await showAddRoomSheet(context);
    if (name == null || !mounted) return;
    AppScope.read(context).addRoom(Room(name: name));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final rooms = app.rooms;
    final tileHeight = AppSizes.scaled(context, _tileHeight);
    return TabPage(
      title: 'Rooms',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: tileHeight,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: rooms.length + (_editing ? 1 : 0),
          itemBuilder: (_, i) => i < rooms.length
              ? _RoomTile(
                  key: ObjectKey(rooms[i]),
                  room: rooms[i],
                  count: app.countIn(rooms[i]),
                  onTap: _editing ? null : () => _open(rooms[i]),
                  // Phải còn ít nhất 1 phòng.
                  onRemove: _editing && app.canRemoveRoom
                      ? () => _remove(rooms[i])
                      : null,
                )
              : AddTile(label: 'Add Room', onTap: _add, height: tileHeight),
        ),
        const SizedBox(height: 16),
        DashedBox(
          onTap: () => setState(() => _editing = !_editing),
          child: AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Row(
              key: ValueKey(_editing),
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Icon(
                  _editing ? Icons.check_rounded : Icons.edit_rounded,
                  size: 20,
                  color: AppColors.dark,
                ),
                Text(
                  _editing ? 'Done' : 'Manage',
                  style: AppText.body(size: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ô phòng: icon màu có quầng, tên, số thiết bị. Có [onRemove] → nút trừ đỏ.
class _RoomTile extends StatelessWidget {
  const _RoomTile({
    super.key,
    required this.room,
    required this.count,
    required this.onTap,
    required this.onRemove,
  });

  final Room room;
  final int count;
  final VoidCallback? onTap, onRemove;

  @override
  Widget build(BuildContext context) {
    final onRemove = this.onRemove;
    return Stack(
      children: [
        Positioned.fill(
          child: AppCard(
            onTap: onTap,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoomBadge(room: room, glow: true),
                const SizedBox(height: 12),
                Text(
                  room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.name,
                ),
                const SizedBox(height: 2),
                Text(
                  plural(count, 'Device'),
                  maxLines: 1,
                  style: AppText.body(color: AppColors.grey),
                ),
              ],
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: RemoveBadge(
              label: 'Remove ${room.name}',
              size: 24,
              onTap: onRemove,
            ),
          ),
      ],
    );
  }
}
