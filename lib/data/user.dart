import 'package:flutter/material.dart';

import 'country.dart';

/// Hồ sơ người dùng (nhập lúc đăng ký, sửa ở màn Profile).
@immutable
class Profile {
  const Profile({
    required this.name,
    required this.country,
    required this.phone,
    required this.email,
  });

  final String name;
  final Country country;
  final String phone;
  final String email;

  Profile copyWith({
    String? name,
    Country? country,
    String? phone,
    String? email,
  }) => Profile(
    name: name ?? this.name,
    country: country ?? this.country,
    phone: phone ?? this.phone,
    email: email ?? this.email,
  );
}

/// Các công tắc ở tab Settings. Thêm tuỳ chọn mới: thêm 1 dòng ở đây,
/// tab Settings tự hiện thêm 1 công tắc.
enum Preference {
  wireless('Wireless Connectivity', Icons.wifi_rounded, true),
  notifications('Get Notifications', Icons.notifications_rounded, false),
  saveDeviceData('Save device data', Icons.download_rounded, false);

  const Preference(this.label, this.icon, this.initial);
  final String label;
  final IconData icon;

  /// Giá trị khi mới cài app.
  final bool initial;
}
