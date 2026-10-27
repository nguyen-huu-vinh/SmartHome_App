import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Đường dẫn ảnh dùng trực tiếp trong giao diện.
/// Ảnh của từng thiết bị nằm cùng dữ liệu, xem `data/sample_data.dart`.
abstract final class AppImages {
  static const onboarding = [
    'assets/images/hero_rect.png',
    'assets/images/hero2_rect.png',
    'assets/images/hero3_rect.png',
  ];

  /// Ảnh nền các màn đăng nhập/đăng ký (750x622).
  static const authHero = 'assets/images/hero4_clean.png';
  static const authHeroRatio = 622 / 750;

  /// Ảnh lớn của máy hút bụi trong bảng chi tiết (cắt sát mép trái).
  static const cleanerHero = 'assets/images/home/cleaner.png';
}

/// Icon SVG trong assets/icons. Thêm icon mới: thêm 1 dòng ở đây.
enum AppIcon {
  email('letter 2'),
  lock('lock-password 1'),
  eye('eye 1'),
  eyeClosed('eye-closed 1'),
  google('google-178 1'),
  phone('phone-calling-rounded 1');

  const AppIcon(this.file);
  final String file;

  String get path => 'assets/icons/Property 1=$file.svg';

  Widget widget([double size = 24]) =>
      SvgPicture.asset(path, width: size, height: size);
}
