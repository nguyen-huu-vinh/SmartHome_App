import 'package:flutter/material.dart';

import '../../core/feedback.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/home_device.dart';
import '../../data/room.dart';
import '../../l10n/l10n.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_image.dart';
import '../../widgets/badges.dart';
import '../../widgets/dashed_box.dart';
import '../../widgets/device_cards.dart';
import '../../widgets/device_sheet/device_sheet.dart';
import '../../widgets/headers.dart';
import '../../widgets/layout.dart';
import '../setup/add_devices_screen.dart';

/// Chi tiết 1 phòng: đèn cuộn ngang, các thiết bị khác xếp 2 cột so le,
/// máy hút bụi thẻ ngang, cuối cùng là ô thêm thiết bị.
class RoomDetailsScreen extends StatelessWidget {
  const RoomDetailsScreen({super.key, required this.room});

  final Room room;

  void _addDevice(BuildContext context) =>
      Navigator.push(context, smoothRoute(const AddDevicesScreen()));

  /// Hỏi lại → xoá phòng, quay về; thông báo có nút hoàn tác.
  Future<void> _removeRoom(BuildContext context) async {
    final ok = await context.confirm(
      title: context.l10n.removeRoomTitle(room.name),
      message: context.l10n.removeRoomMessage,
      confirmLabel: context.l10n.remove,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final app = AppScope.read(context);
    final i = app.removeRoom(room);
    if (i == null) return;
    Navigator.pop(context);
    context.toast(
      context.l10n.removedNamed(room.name),
      action: context.l10n.undo,
      onAction: () => app.insertRoom(i, room),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final devices = app.inRoom(room.name);
    final lights = [
      for (final d in devices)
        if (d.group == DeviceGroup.lights) d,
    ];
    final cleaners = [
      for (final d in devices)
        if (d.group == DeviceGroup.cleaning) d,
    ];
    final others = [
      for (final d in devices)
        if (d.group != DeviceGroup.lights && d.group != DeviceGroup.cleaning) d,
    ];
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: room.name,
            titleSize: 20,
            subtitle: context.l10n.devicesCount(devices.length),
            leading: RoomBadge(room: room, size: 52, glow: true),
            actions: [
              PopupMenuButton<VoidCallback>(
                tooltip: context.l10n.more,
                icon: const Icon(Icons.more_horiz, color: AppColors.dark),
                position: PopupMenuPosition.under,
                onSelected: (action) => action(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: () => _addDevice(context),
                    child: Text(context.l10n.addNewDevice),
                  ),
                  // Phải còn ít nhất 1 phòng.
                  if (app.canRemoveRoom)
                    PopupMenuItem(
                      value: () => _removeRoom(context),
                      child: Text(
                        context.l10n.removeRoom,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Expanded(
            child: AppRefresh(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 24,
                  bottom: MediaQuery.paddingOf(context).bottom + 24,
                ),
                children: [
                  if (lights.isNotEmpty) ...[
                    HorizontalList(
                      height: AppSizes.scaled(
                        context,
                        deviceCardHeight(DeviceGroup.lights),
                      ),
                      itemCount: lights.length,
                      itemBuilder: (_, i) => LightCard(
                        device: lights[i],
                        on: app.isOn(lights[i]),
                        onChanged: (v) => app.setOn(lights[i], v),
                        width: 220,
                        onTap: () => showDeviceSheet(context, lights[i]),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _pad(_Masonry(devices: others)),
                  for (final d in cleaners) ...[
                    _pad(_CleanerTile(device: d)),
                    const SizedBox(height: 16),
                  ],
                  if (devices.isEmpty)
                    EmptyState(
                      icon: Icons.devices_other_rounded,
                      message: context.l10n.noDevicesInRoom,
                      padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                    ),
                  _pad(
                    AddTile(
                      label: context.l10n.addNewDevice,
                      onTap: () => _addDevice(context),
                      height: 56,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _pad(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
    child: child,
  );
}

/// 2 cột so le: mỗi thẻ vào cột đang thấp hơn (ước theo chiều cao ảnh).
class _Masonry extends StatelessWidget {
  const _Masonry({required this.devices});

  final List<HomeDevice> devices;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) return const SizedBox.shrink();
    final cols = [<HomeDevice>[], <HomeDevice>[]];
    final heights = [0.0, 0.0];
    for (final d in devices) {
      final c = heights[0] <= heights[1] ? 0 : 1;
      cols[c].add(d);
      heights[c] += _TallTile.estimate(d) + 16;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          for (final col in cols)
            Expanded(
              child: Column(
                spacing: 16,
                children: [for (final d in col) _TallTile(device: d)],
              ),
            ),
        ],
      ),
    );
  }
}

/// Thẻ dọc: ảnh, tên, trạng thái, điện áp. Máy lạnh có thêm nút −/+ nhiệt độ.
class _TallTile extends StatelessWidget {
  const _TallTile({required this.device});

  final HomeDevice device;

  static double _imageHeight(HomeDevice d) => switch (d.group) {
    DeviceGroup.climate => 64,
    DeviceGroup.appliances => 150,
    _ => 110,
  };

  /// Chiều cao ước tính để chia cột.
  static double estimate(HomeDevice d) =>
      _imageHeight(d) + 120 + (d.group == DeviceGroup.climate ? 60 : 0);

  @override
  Widget build(BuildContext context) {
    final on = AppScope.of(context).isOn(device);
    // Camera luôn bật → "Connected"; còn lại theo công tắc.
    final status = device.switchable
        ? (on ? context.l10n.poweredOn : context.l10n.poweredOff)
        : (on ? context.l10n.connected : context.l10n.offline);
    return AppCard(
      radius: AppSizes.radiusL,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      onTap: () => showDeviceSheet(context, device),
      child: Column(
        children: [
          SizedBox(
            height: _imageHeight(device),
            width: double.infinity,
            child: AppImage(device.image),
          ),
          const SizedBox(height: 16),
          Text(
            device.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.name,
          ),
          const SizedBox(height: 6),
          StatusDot(status, active: on),
          const SizedBox(height: 10),
          IconLabel(text: context.l10n.voltsToday(device.volts)),
          if (device.group == DeviceGroup.climate) ...[
            const SizedBox(height: 14),
            _TempControl(device: device, on: on),
          ],
        ],
      ),
    );
  }
}

/// [−]  ❄ 25  [+] — tắt máy thì mờ và khoá.
class _TempControl extends StatelessWidget {
  const _TempControl({required this.device, required this.on});

  final HomeDevice device;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final ac = app.ac(device);
    Widget button(IconData icon, String tip, int d) => Expanded(
      child: Tooltip(
        message: tip,
        child: AppCard(
          radius: AppSizes.radiusS,
          color: AppColors.surface,
          shadow: null,
          height: 44,
          onTap: () => app.update(() => ac.setTemp(ac.temp + d)),
          child: Center(child: Icon(icon, color: AppColors.dark)),
        ),
      ),
    );
    return Dimmed(
      enabled: on,
      child: Row(
        spacing: 8,
        children: [
          button(Icons.remove_rounded, context.l10n.temperatureDown, -1),
          Semantics(
            label: context.l10n.temperatureDegrees(ac.temp),
            child: ExcludeSemantics(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.ac_unit_rounded,
                    size: 16,
                    color: AppColors.brand,
                  ),
                  Text('${ac.temp}', style: AppText.semibold(20)),
                ],
              ),
            ),
          ),
          button(Icons.add_rounded, context.l10n.temperatureUp, 1),
        ],
      ),
    );
  }
}

/// Thẻ ngang của máy hút bụi: ảnh, tên, kết nối + pin, trạng thái sạc.
class _CleanerTile extends StatelessWidget {
  const _CleanerTile({required this.device});

  final HomeDevice device;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.cleaner(device);
    final state = s.charging
        ? context.l10n.onCharge
        : app.isOn(device)
        ? context.l10n.cleaning
        : context.l10n.idle;
    return AppCard(
      radius: AppSizes.radiusL,
      padding: const EdgeInsets.all(16),
      onTap: () => showDeviceSheet(context, device),
      child: Row(
        spacing: 16,
        children: [
          AppImage(device.image, width: 96),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.name,
                ),
                Row(
                  spacing: 8,
                  children: [
                    Flexible(child: StatusDot(context.l10n.connected)),
                    BatteryBadge(level: s.battery, charging: s.charging),
                  ],
                ),
                IconLabel(text: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
