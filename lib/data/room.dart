import 'package:flutter/material.dart';

/// Phòng trong nhà, có icon + màu riêng. Thiết bị gắn với phòng qua [name].
@immutable
class Room {
  const Room({
    required this.name,
    this.icon = Icons.meeting_room_rounded,
    this.color = const Color(0xFF8E8E9A),
  });

  final String name;
  final IconData icon;
  final Color color;
}
