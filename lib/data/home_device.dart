import 'package:flutter/foundation.dart';

/// Nhóm hiển thị ở màn Home; mỗi nhóm 1 kiểu thẻ và 1 kiểu bảng chi tiết.
enum DeviceGroup {
  lights('Lights & Decoration', 'Light', 'Light'),
  security('Security', 'Security', 'Camera'),
  entertainment('Entertainment', 'Entertainment', 'Device'),
  climate('Climate', 'Climate', 'Device'),
  appliances('Appliances', 'Appliances', 'Device'),
  cleaning('Cleaning', 'Cleaning', 'Device');

  const DeviceGroup(this.title, this.listTitle, this.unit);

  /// Tiêu đề mục ở màn Home.
  final String title;

  /// Tiêu đề màn "View all".
  final String listTitle;

  /// Đơn vị đếm (số ít), VD: "1 Light", "12 Lights".
  final String unit;
}

/// Thiết bị đã thêm vào nhà.
@immutable
class HomeDevice {
  const HomeDevice({
    required this.name,
    required this.image,
    required this.group,
    required this.room,
    this.on = false,
    this.preview,
    this.volts = 220,
  });

  final String name;
  final String image;
  final DeviceGroup group;

  /// Tên phòng (khớp [Room.name]).
  final String room;

  /// Trạng thái bật/tắt ban đầu (trạng thái hiện tại do `AppState` giữ).
  final bool on;

  /// Ảnh xem trước của camera (null = chưa có hình).
  final String? preview;

  /// Điện áp đo được hôm nay — giả lập.
  final int volts;

  /// Camera luôn bật, không có công tắc.
  bool get switchable => group != DeviceGroup.security;
}
