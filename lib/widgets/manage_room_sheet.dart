import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/app_state.dart';
import '../data/room.dart';
import 'app_buttons.dart';
import 'app_sheet.dart';
import 'dashed_box.dart';
import 'layout.dart';
import 'room_cards.dart';

/// Bảng "Manage Room": chọn phòng, thêm thiết bị vào phòng.
/// Bấm Continue → trả về phòng đang chọn; ✕ hoặc vuốt xuống → null.
Future<Room?> showManageRoomSheet(
  BuildContext context, {
  required Room initial,
  required void Function(Room room) onAddDevice,
}) => showAppSheet<Room>(
  context,
  builder: (_) => _ManageRoomSheet(initial: initial, onAddDevice: onAddDevice),
);

class _ManageRoomSheet extends StatefulWidget {
  const _ManageRoomSheet({required this.initial, required this.onAddDevice});

  final Room initial;
  final void Function(Room room) onAddDevice;

  @override
  State<_ManageRoomSheet> createState() => _ManageRoomSheetState();
}

class _ManageRoomSheetState extends State<_ManageRoomSheet> {
  static const _gap = 16.0;

  late var _room = widget.initial;

  /// Mở bảng → cuộn ngang tới phòng đang chọn.
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final i = AppScope.read(context).rooms.indexOf(_room);
      if (i < 0) return;
      _scroll.jumpTo(
        (i * (RoomCard.width + _gap)).clamp(
          0,
          _scroll.position.maxScrollExtent,
        ),
      );
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = AppScope.of(context).rooms;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(title: 'Manage Room'),
            const SizedBox(height: 12),
            HorizontalList(
              controller: _scroll,
              height: AppSizes.scaled(context, 76),
              padding: EdgeInsets.zero,
              spacing: _gap,
              itemCount: rooms.length,
              itemBuilder: (_, i) => RoomCard(
                room: rooms[i],
                selected: rooms[i] == _room,
                selectedColor: rooms[i].color,
                onTap: () => setState(() => _room = rooms[i]),
              ),
            ),
            const SizedBox(height: 24),
            AddTile(
              label: 'Add New Device',
              onTap: () => widget.onAddDevice(_room),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Continue',
              onPressed: () => Navigator.pop(context, _room),
            ),
          ],
        ),
      ),
    );
  }
}
