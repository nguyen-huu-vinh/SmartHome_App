import 'package:flutter/foundation.dart';

/// Nhóm hiển thị ở màn Home; mỗi nhóm 1 kiểu thẻ và 1 kiểu bảng chi tiết.
/// Tên hiển thị: `g.title(context.l10n)` (xem `l10n.dart`).
enum DeviceGroup {
  lights,
  security,
  entertainment,
  climate,
  appliances,
  cleaning,
}

/// Thiết bị đã thêm vào nhà. 2 thiết bị cùng [id] là 1 thiết bị.
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
    String? id,
  }) : id = id ?? '$room/$name';

  /// Mã do server đặt. Chưa có (thiết bị mới, mẫu) → "phòng/tên".
  final String id;
  final String name;
  final String image;
  final DeviceGroup group;

  /// Tên phòng (khớp [Room.name]).
  final String room;

  /// Trạng thái bật/tắt server đang lưu.
  final bool on;

  /// Ảnh xem trước của camera (null = chưa có hình).
  final String? preview;

  /// Điện áp đo được hôm nay — giả lập.
  final int volts;

  HomeDevice copyWith({String? id, bool? on}) => HomeDevice(
    id: id ?? this.id,
    name: name,
    image: image,
    group: group,
    room: room,
    on: on ?? this.on,
    preview: preview,
    volts: volts,
  );

  /// Dữ liệu gửi / nhận với server.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'group': group.name,
    'room': room,
    'on': on,
    'preview': preview,
    'volts': volts,
  };

  factory HomeDevice.fromJson(Map<String, Object?> json) => HomeDevice(
    id: json['id'] as String,
    name: json['name'] as String,
    image: json['image'] as String,
    group: DeviceGroup.values.byName(json['group'] as String),
    room: json['room'] as String,
    on: json['on'] as bool? ?? false,
    preview: json['preview'] as String?,
    volts: (json['volts'] as num?)?.toInt() ?? 220,
  );

  @override
  bool operator ==(Object other) => other is HomeDevice && other.id == id;

  @override
  int get hashCode => id.hashCode;

  /// Camera luôn bật, không có công tắc.
  bool get switchable => group != DeviceGroup.security;
}
