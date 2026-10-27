import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/device_settings.dart';
import '../app_card.dart';
import '../app_image.dart';
import 'stat_card.dart';

// Phần riêng của camera trong bảng chi tiết: hình đang quay, ô chọn camera
// theo phòng, số liệu.

/// Hình đang quay. Chưa có hình → nền tối có icon; camera tắt → phủ tối
/// "Camera off".
class CameraFeed extends StatelessWidget {
  const CameraFeed({
    super.key,
    required this.preview,
    required this.on,
    this.height = 200,
    this.radius = 24,
  });

  final String? preview;
  final bool on;
  final double height, radius;

  @override
  Widget build(BuildContext context) {
    final preview = this.preview;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (preview != null)
              AppImage(preview, fit: BoxFit.cover)
            else
              const ColoredBox(
                color: Color(0xFF2A2B31),
                child: Icon(
                  Icons.videocam_off_rounded,
                  color: Colors.white54,
                  size: 32,
                ),
              ),
            AnimatedOpacity(
              duration: AppMotion.medium,
              opacity: on ? 0 : 1,
              child: ColoredBox(
                color: const Color(0xCC1A1A1F),
                child: Center(
                  child: Text(
                    'Camera off',
                    style: AppText.body(size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ô chọn camera: hình xem trước + tên phòng + biểu tượng đang phát.
class CameraRoomCard extends StatelessWidget {
  const CameraRoomCard({
    super.key,
    required this.room,
    required this.preview,
    required this.live,
    required this.selected,
    required this.onTap,
  });

  static const width = 146.0;

  final String room;
  final String? preview;
  final bool live, selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: width,
      padding: const EdgeInsets.all(6),
      selected: selected,
      selectedWidth: 1.5,
      haptic: true,
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: CameraFeed(
              preview: preview,
              on: live,
              height: double.infinity,
              radius: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 2, 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    room,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(size: 16),
                  ),
                ),
                Icon(
                  Icons.wifi_tethering_rounded,
                  size: 16,
                  color: live ? AppColors.success : AppColors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thời gian chạy + chất lượng hình (bấm để đổi).
class CameraStats extends StatelessWidget {
  const CameraStats({super.key, required this.camera, required this.update});

  final CameraSettings camera;
  final void Function(VoidCallback change) update;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: StatCard(
            icon: const Icon(Icons.alarm_rounded, color: Colors.white),
            color: AppColors.brand,
            value: '${camera.runHours} Hr',
            label: 'Run time',
          ),
        ),
        Expanded(
          child: StatCard(
            icon: Text('HD', style: AppText.bold(14, color: Colors.white)),
            color: const Color(0xFFA77CF6),
            value: camera.quality.label,
            label: camera.quality == CameraQuality.defaultValue
                ? 'Quality - Default'
                : 'Quality',
            onTap: () => update(() => camera.quality = camera.quality.next),
          ),
        ),
      ],
    );
  }
}
