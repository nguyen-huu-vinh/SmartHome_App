import 'package:flutter/material.dart';

/// Phòng trong nhà, có icon + màu riêng. Thiết bị gắn với phòng qua [name];
/// 2 phòng cùng tên là 1 phòng.
@immutable
class Room {
  const Room({
    required this.name,
    this.icon = Icons.meeting_room_rounded,
    this.color = const Color(0xFF8E8E9A),
  });

  /// Icon dùng được cho phòng, theo tên gọn để lưu / gửi lên server
  /// (không lưu mã icon để app build gọn được). Icon đầu tiên là mặc định.
  static const icons = <String, IconData>{
    'meeting_room': Icons.meeting_room_rounded,
    'chair': Icons.chair_rounded,
    'kitchen': Icons.soup_kitchen_rounded,
    'bed': Icons.bed_rounded,
    'wardrobe': Icons.checkroom_rounded,
    'cafe': Icons.local_cafe_rounded,
    'sports': Icons.sports_basketball_rounded,
  };

  final String name;
  final IconData icon;
  final Color color;

  /// Dữ liệu gửi / nhận với server.
  Map<String, Object?> toJson() => {
    'name': name,
    'icon': icons.entries
        .firstWhere((e) => e.value == icon, orElse: () => icons.entries.first)
        .key,
    'color': color.toARGB32(),
  };

  factory Room.fromJson(Map<String, Object?> json) => Room(
    name: json['name'] as String,
    icon: icons[json['icon']] ?? icons.values.first,
    color: Color(json['color'] as int),
  );

  @override
  bool operator ==(Object other) => other is Room && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
