import 'package:flutter/foundation.dart';

/// Loại thông báo: gợi ý tắt đèn, hoặc thiết bị mất kết nối / bị tắt.
enum AlertKind { suggestion, disconnected, turnedOff }

/// 1 thông báo ở tab Activity Alerts.
@immutable
class ActivityAlert {
  const ActivityAlert({
    required this.kind,
    required this.title,
    required this.message,
    required this.image,
    required this.age,
    this.room,
  });

  final AlertKind kind;

  /// Tên thiết bị (với gợi ý: giờ gợi ý, VD "11:30 PM").
  final String title;
  final String message;
  final String image;

  /// Đã xảy ra cách đây bao lâu.
  final Duration age;

  /// Gợi ý tắt đèn: phòng có dãy đèn sẽ bị tắt.
  final String? room;

  String get ago => switch (age) {
    Duration(inMinutes: < 1) => 'Just now',
    Duration(inHours: < 1) => '${age.inMinutes} Min ago',
    Duration(inDays: < 1) => '${age.inHours} Hr ago',
    _ => '${age.inDays} Day ago',
  };
}
