// Kiểm tra dữ liệu người dùng nhập (dùng chung cho các form).

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// "name@domain.com" (bỏ khoảng trắng 2 đầu).
bool isValidEmail(String s) => _email.hasMatch(s.trim());

/// Số điện thoại (không gồm mã vùng): 6–15 chữ số.
bool isValidPhone(String s) {
  final digits = s.replaceAll(RegExp(r'\D'), '');
  return digits.length >= 6 && digits.length <= 15;
}

/// Che bớt email: wrteam_design@gmail.com → wrteam*****ign@gmail.com
String maskEmail(String email) {
  final p = email.split('@');
  if (p.length != 2 || p[0].length < 6) return email;
  return '${p[0].substring(0, 6)}*****${p[0].substring(p[0].length - 3)}@${p[1]}';
}
