import 'package:flutter/material.dart';

// Cài đặt riêng của từng loại thiết bị (ngoài bật/tắt).
// Mỗi thiết bị có 1 bản, do `AppState` giữ: `app.light(d)`, `app.ac(d)`, ...
// Sửa cài đặt qua `app.update(...)` để các màn tự vẽ lại.

// ───────────────────────── Đèn ─────────────────────────

class LightSettings {
  static const minBrightness = 1, maxBrightness = 100;

  /// Độ sáng (%).
  int brightness = 33;

  /// Nhiệt độ màu: 0 = vàng ấm, 1 = trắng xanh.
  double warmth = 0.06;

  // Số liệu đọc từ thiết bị — giả lập.
  int runHours = 4;
  int aqi = 72;

  void setBrightness(int v) =>
      brightness = v.clamp(minBrightness, maxBrightness);
}

// ───────────────────────── Máy lạnh ─────────────────────────

/// Tên hiển thị: `mode.label(context.l10n)` (xem `l10n.dart`).
enum AcMode {
  cool(Icons.ac_unit_rounded),
  heat(Icons.wb_sunny_rounded),
  dry(Icons.water_drop_rounded),
  fan(Icons.air_rounded),
  auto(Icons.autorenew_rounded);

  const AcMode(this.icon);
  final IconData icon;

  AcMode get next => values[(index + 1) % values.length];
}

enum AcFan {
  auto,
  low,
  medium,
  high;

  AcFan get next => values[(index + 1) % values.length];
}

class AcSettings {
  static const minTemp = 16, maxTemp = 30;

  int temp = 21;
  AcMode mode = AcMode.cool;
  AcFan fan = AcFan.auto;
  bool swingLeft = false, swingRight = false;
  bool energySaving = false, highCooling = false;

  /// Đảo gió tự động = cả 2 hướng.
  bool get autoSwing => swingLeft && swingRight;

  set autoSwing(bool v) => swingLeft = swingRight = v;

  void setTemp(int t) => temp = t.clamp(minTemp, maxTemp);
}

// ───────────────────────── Camera ─────────────────────────

enum CameraQuality {
  hd('720p (HD)'),
  fullHd('1080p (HD)'),
  qhd('2K (QHD)');

  const CameraQuality(this.label);
  final String label;

  static const defaultValue = fullHd;

  CameraQuality get next => values[(index + 1) % values.length];
}

class CameraSettings {
  static const maxPan = 360;

  /// Góc xoay ngang 0–360°.
  int pan = 120;
  CameraQuality quality = CameraQuality.defaultValue;

  // Số liệu đọc từ thiết bị — giả lập.
  int runHours = 124;

  void setPan(int v) => pan = v.clamp(0, maxPan);
}

// ───────────────────────── Máy hút bụi ─────────────────────────

/// Buổi trong ngày để hẹn giờ dọn.
enum CleanTime { morning, noon, evening, night }

class CleanerSettings {
  static const maxMinutes = 60;
  static const minBreak = 5, maxBreak = 120;

  /// Thời gian dọn mỗi lượt, 1–60 phút.
  int minutes = 46;

  /// Nghỉ giữa các lượt (giây).
  int breakSec = 45;

  bool scheduled = true;
  CleanTime time = CleanTime.morning;

  // Số liệu đọc từ thiết bị — giả lập.
  int battery = 23;
  bool charging = true;

  void setMinutes(int v) => minutes = v.clamp(1, maxMinutes);
  void setBreak(int v) => breakSec = v.clamp(minBreak, maxBreak);
}
