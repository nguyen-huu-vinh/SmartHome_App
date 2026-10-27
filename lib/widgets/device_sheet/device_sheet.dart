import 'package:flutter/material.dart';

import '../../core/feedback.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/device_settings.dart';
import '../../data/home_device.dart';
import '../app_image.dart';
import '../app_sheet.dart';
import '../badges.dart';
import '../device_controls.dart';
import '../layout.dart';
import '../room_cards.dart';
import 'ac_panel.dart';
import 'camera_panel.dart';
import 'cleaner_sheet.dart';
import 'light_panel.dart';
import 'value_dial.dart';

/// Mở bảng chi tiết của [device]. Trạng thái đọc / ghi thẳng vào `AppState`,
/// nên mọi màn đang mở phía sau cũng cập nhật theo.
Future<void> showDeviceSheet(BuildContext context, HomeDevice device) =>
    showAppSheet(
      context,
      builder: (_) => switch (device.group) {
        DeviceGroup.cleaning => CleanerSheet(device: device),
        _ => DeviceSheet(device: device),
      },
    );

/// Bảng chi tiết chung. Các máy cùng mẫu ở nhiều phòng được gom lại:
/// chọn phòng để điều khiển máy của phòng đó.
///
/// Khung chung: tiêu đề, ảnh, chọn phòng, giá trị + nút nguồn.
/// Phần riêng: đèn → nhiệt độ màu + số liệu; máy lạnh → remote;
/// camera → hình đang quay + số liệu; thiết bị khác → trạng thái + điện áp.
class DeviceSheet extends StatefulWidget {
  const DeviceSheet({super.key, required this.device});

  final HomeDevice device;

  @override
  State<DeviceSheet> createState() => _DeviceSheetState();
}

class _DeviceSheetState extends State<DeviceSheet> {
  late var _unit = widget.device;

  /// Danh sách phòng ngang: mở bảng thì cuộn tới ô đang chọn.
  final _rooms = ScrollController();

  DeviceGroup get _group => widget.device.group;
  bool get _camera => _group == DeviceGroup.security;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_rooms.hasClients) return;
      final units = AppScope.read(context).unitsOf(widget.device);
      final width = _camera ? CameraRoomCard.width : RoomCard.width;
      final target = units.indexOf(_unit) * (width + 16);
      _rooms.jumpTo(target.clamp(0, _rooms.position.maxScrollExtent));
    });
  }

  @override
  void dispose() {
    _rooms.dispose();
    super.dispose();
  }

  void _select(HomeDevice d) => setState(() => _unit = d);

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final units = app.unitsOf(widget.device);
    final on = app.isOn(_unit);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              title: widget.device.name,
              subtitle: plural(units.length, 'Device'),
              // Camera: ảnh thiết bị nhỏ cạnh tên.
              leading: _camera
                  ? AppImage(widget.device.image, width: 48, height: 48)
                  : null,
            ),
            const SizedBox(height: 16),
            switch (_group) {
              DeviceGroup.lights => LampImage(
                image: _unit.image,
                on: on,
                light: app.light(_unit),
              ),
              DeviceGroup.security => CameraFeed(
                preview: _unit.preview,
                on: on,
              ),
              _ => GlowImage(image: _unit.image, on: on),
            },
            const SizedBox(height: 16),
            HorizontalList(
              controller: _rooms,
              height: AppSizes.scaled(context, _camera ? 140 : 86),
              padding: EdgeInsets.zero,
              itemCount: units.length,
              itemBuilder: (_, i) {
                final u = units[i];
                return _camera
                    ? CameraRoomCard(
                        room: u.room,
                        preview: u.preview,
                        live: app.isOn(u),
                        selected: u == _unit,
                        onTap: () => _select(u),
                      )
                    : RoomCard(
                        room: app.roomNamed(u.room),
                        selected: u == _unit,
                        onTap: () => _select(u),
                      );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Tắt máy → mờ và khoá các điều khiển, trừ nút nguồn.
                Expanded(
                  child: Dimmed(enabled: on, child: _valueRow(app, on)),
                ),
                const SizedBox(width: 12),
                PowerBox(on: on, onChanged: (v) => app.setOn(_unit, v)),
              ],
            ),
            ..._panel(app, on),
          ],
        ),
      ),
    );
  }

  /// Giá trị chính + thước kéo: đèn → độ sáng, máy lạnh → nhiệt độ,
  /// camera → góc xoay; thiết bị khác → trạng thái + điện áp.
  Widget _valueRow(AppState app, bool on) {
    switch (_group) {
      case DeviceGroup.lights:
        final light = app.light(_unit);
        return DialRow(
          icon: Icons.wb_sunny_outlined,
          iconColor: AppColors.amber,
          dial: ValueDial(
            label: 'Brightness',
            value: light.brightness,
            min: LightSettings.minBrightness,
            max: LightSettings.maxBrightness,
            format: (v) => '$v%',
            stepPx: 4, // 4px kéo = 1%
            onStep: (d) =>
                app.update(() => light.setBrightness(light.brightness + d)),
          ),
        );
      case DeviceGroup.security:
        final cam = app.camera(_unit);
        return DialRow(
          icon: Icons.rotate_left_rounded,
          iconColor: AppColors.dark,
          dial: ValueDial(
            label: 'Camera angle',
            value: cam.pan,
            min: 0,
            max: CameraSettings.maxPan,
            format: (v) => '$v°',
            stepPx: 3, // 3px kéo = 1°
            onStep: (d) => app.update(() => cam.setPan(cam.pan + d)),
          ),
        );
      case DeviceGroup.climate:
        final ac = app.ac(_unit);
        return DialRow(
          icon: ac.mode.icon,
          iconColor: AppColors.brand,
          dial: ValueDial(
            label: 'Temperature',
            value: ac.temp,
            min: AcSettings.minTemp,
            max: AcSettings.maxTemp,
            format: (v) => '$v°',
            stepPx: 12, // 12px kéo = 1°
            onStep: (d) => app.update(() => ac.setTemp(ac.temp + d)),
          ),
        );
      case DeviceGroup.entertainment ||
          DeviceGroup.appliances ||
          DeviceGroup.cleaning:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            StatusDot(on ? 'Powered On' : 'Powered Off', active: on),
            IconLabel(text: '${_unit.volts}V - Today'),
          ],
        );
    }
  }

  /// Phần riêng theo nhóm, nằm dưới hàng nút nguồn.
  List<Widget> _panel(AppState app, bool on) => switch (_group) {
    DeviceGroup.lights => [
      const SizedBox(height: 28),
      Dimmed(
        enabled: on,
        child: LightPanel(light: app.light(_unit), update: app.update),
      ),
    ],
    DeviceGroup.security => [
      const SizedBox(height: 28),
      Dimmed(
        enabled: on,
        child: CameraStats(camera: app.camera(_unit), update: app.update),
      ),
    ],
    DeviceGroup.climate => [
      const SizedBox(height: 28),
      Center(child: RemoteBadge(on: on)),
      const SizedBox(height: 24),
      Dimmed(
        enabled: on,
        child: AcRemote(ac: app.ac(_unit), update: app.update),
      ),
    ],
    DeviceGroup.entertainment ||
    DeviceGroup.appliances ||
    DeviceGroup.cleaning => const [],
  };
}
