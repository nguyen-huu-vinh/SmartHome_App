import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/app_state.dart';
import '../data/home_device.dart';
import 'app_card.dart';
import 'app_image.dart';
import 'badges.dart';
import 'device_controls.dart';
import 'device_sheet/device_sheet.dart';

// Các kiểu thẻ thiết bị. Thẻ chỉ vẽ; trạng thái do nơi dùng truyền vào —
// hoặc dùng [DeviceCard] để tự lấy từ AppState.

/// Chiều cao thẻ theo nhóm (dùng chung Home và "View all").
double deviceCardHeight(DeviceGroup g) => switch (g) {
  DeviceGroup.lights => 168,
  DeviceGroup.security => 184,
  DeviceGroup.entertainment ||
  DeviceGroup.climate ||
  DeviceGroup.appliances ||
  DeviceGroup.cleaning => 108,
};

/// Thẻ đúng kiểu theo nhóm của [device], tự lấy trạng thái từ [AppScope].
/// Bấm thẻ → bảng chi tiết. [width] = double.infinity → giãn hết chiều ngang.
/// Mẫu có ở nhiều phòng → dòng trạng thái là tên phòng.
class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key, required this.device, this.width});

  final HomeDevice device;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final d = device;
    final on = app.isOn(d);
    final room = app.isMultiRoom(d) ? d.room : null;
    void onChanged(bool v) => app.setOn(d, v);
    void open() => showDeviceSheet(context, d);
    return switch (d.group) {
      DeviceGroup.lights => LightCard(
        device: d,
        on: on,
        onChanged: onChanged,
        width: width ?? 195,
        status: room ?? 'Connected',
        onTap: open,
      ),
      DeviceGroup.security => CameraCard(
        device: d,
        on: on,
        width: width ?? 200,
        room: room,
        onTap: open,
      ),
      DeviceGroup.entertainment ||
      DeviceGroup.climate ||
      DeviceGroup.appliances ||
      DeviceGroup.cleaning => MediaCard(
        device: d,
        on: on,
        onChanged: onChanged,
        width: width ?? 262,
        status: room ?? 'Connected',
        onTap: open,
      ),
    };
  }
}

/// Thẻ lớn đầu trang Home: trạng thái, tên to, nút nguồn, ảnh bên phải.
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    super.key,
    required this.device,
    required this.on,
    required this.onChanged,
    this.onTap,
  });

  final HomeDevice device;
  final bool on;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
      shadow: AppShadows.raised,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusDot('Connected'),
                const SizedBox(height: 8),
                Text(
                  device.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bold(28, height: 1.2),
                ),
                const Spacer(),
                PowerPill(on: on, onChanged: onChanged),
              ],
            ),
          ),
          Expanded(flex: 4, child: AppImage(device.image)),
        ],
      ),
    );
  }
}

/// Thẻ đèn: ảnh + công tắc dọc OFF/ON, tên, trạng thái.
class LightCard extends StatelessWidget {
  const LightCard({
    super.key,
    required this.device,
    required this.on,
    required this.onChanged,
    this.width = 195,
    this.status = 'Connected',
    this.onTap,
  });

  final HomeDevice device;
  final bool on;
  final ValueChanged<bool> onChanged;
  final double width;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: width,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      shadow: null,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh đèn treo chạm mép trên thẻ như thiết kế.
                Expanded(
                  child: AppImage(device.image, alignment: Alignment.topLeft),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: VerticalSwitch(on: on, onChanged: onChanged),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            device.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.name,
          ),
          const SizedBox(height: 4),
          StatusDot(status),
        ],
      ),
    );
  }
}

/// Thẻ camera: ảnh giữa, tên, "Online" / tên phòng.
class CameraCard extends StatelessWidget {
  const CameraCard({
    super.key,
    required this.device,
    required this.on,
    this.width = 200,
    this.room,
    this.onTap,
  });

  final HomeDevice device;
  final bool on;
  final double width;

  /// Tên phòng thay cho "Online" khi cùng mẫu có ở nhiều phòng.
  final String? room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: width,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      shadow: null,
      onTap: onTap,
      child: Column(
        children: [
          Expanded(child: AppImage(device.image)),
          const SizedBox(height: 12),
          Text(
            device.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.name,
          ),
          const SizedBox(height: 4),
          StatusDot(on ? room ?? 'Online' : 'Offline', active: on),
        ],
      ),
    );
  }
}

/// Thẻ ngang: ảnh trái, tên, trạng thái, "Power On/Off" + công tắc.
/// Dùng cho giải trí, máy lạnh, thiết bị gia dụng, máy hút bụi.
class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.device,
    required this.on,
    required this.onChanged,
    this.width = 262,
    this.status = 'Connected',
    this.onTap,
  });

  final HomeDevice device;
  final bool on;
  final ValueChanged<bool> onChanged;
  final double width;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: width,
      padding: const EdgeInsets.all(12),
      shadow: null,
      onTap: onTap,
      child: Row(
        spacing: 12,
        children: [
          SizedBox(width: 72, child: AppImage(device.image)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.name,
                ),
                const SizedBox(height: 4),
                StatusDot(status),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: AppMotion.fast,
                        style: AppText.body(
                          size: 16,
                          color: on ? AppColors.brand : AppColors.grey,
                        ),
                        child: Text(
                          on ? 'Power On' : 'Power Off',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    PowerSwitch(on: on, onChanged: onChanged),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
