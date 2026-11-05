import 'package:flutter/widgets.dart';

import '../data/activity_alert.dart';
import '../data/device_settings.dart';
import '../data/home_device.dart';
import '../data/user.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Lấy câu chữ theo ngôn ngữ đang chọn: `context.l10n.continueLabel`.
///
/// Câu chữ nằm trong `app_en.arb` (bản gốc) và `app_vi.arb`. Thêm câu mới:
/// thêm vào cả 2 file rồi chạy `flutter gen-l10n`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// Tên hiển thị của các giá trị trong app, theo ngôn ngữ.

extension DeviceGroupL10n on DeviceGroup {
  /// Tiêu đề mục ở màn Home.
  String title(AppLocalizations l) => switch (this) {
    DeviceGroup.lights => l.groupLights,
    DeviceGroup.security => l.groupSecurity,
    DeviceGroup.entertainment => l.groupEntertainment,
    DeviceGroup.climate => l.groupClimate,
    DeviceGroup.appliances => l.groupAppliances,
    DeviceGroup.cleaning => l.groupCleaning,
  };

  /// Tiêu đề màn "View all".
  String listTitle(AppLocalizations l) =>
      this == DeviceGroup.lights ? l.groupLightsList : title(l);

  /// "1 Light", "12 Lights", "3 Cameras", "5 Devices".
  String count(AppLocalizations l, int n) => switch (this) {
    DeviceGroup.lights => l.lightsCount(n),
    DeviceGroup.security => l.camerasCount(n),
    _ => l.devicesCount(n),
  };
}

extension AcModeL10n on AcMode {
  String label(AppLocalizations l) => switch (this) {
    AcMode.cool => l.acModeCool,
    AcMode.heat => l.acModeHeat,
    AcMode.dry => l.acModeDry,
    AcMode.fan => l.acModeFan,
    AcMode.auto => l.acModeAuto,
  };
}

extension AcFanL10n on AcFan {
  String label(AppLocalizations l) => switch (this) {
    AcFan.auto => l.fanAuto,
    AcFan.low => l.fanLow,
    AcFan.medium => l.fanMedium,
    AcFan.high => l.fanHigh,
  };
}

extension CleanTimeL10n on CleanTime {
  String label(AppLocalizations l) => switch (this) {
    CleanTime.morning => l.morning,
    CleanTime.noon => l.noon,
    CleanTime.evening => l.evening,
    CleanTime.night => l.night,
  };
}

extension PreferenceL10n on Preference {
  String label(AppLocalizations l) => switch (this) {
    Preference.wireless => l.prefWireless,
    Preference.notifications => l.prefNotifications,
    Preference.saveDeviceData => l.prefSaveData,
  };
}

extension LightSettingsL10n on LightSettings {
  /// Chất lượng không khí: tốt / trung bình / không tốt.
  String aqiLabel(AppLocalizations l) => switch (aqi) {
    <= 50 => l.aqiGood,
    <= 100 => l.aqiModerate,
    _ => l.aqiUnhealthy,
  };
}

extension ActivityAlertL10n on ActivityAlert {
  /// Đã xảy ra cách đây bao lâu: "Just now", "5 Min ago"...
  String ago(AppLocalizations l) => switch (age) {
    Duration(inMinutes: < 1) => l.justNow,
    Duration(inHours: < 1) => l.minutesAgo(age.inMinutes),
    Duration(inDays: < 1) => l.hoursAgo(age.inHours),
    _ => l.daysAgo(age.inDays),
  };
}
