import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthome_app/data/app_state.dart';
import 'package:smarthome_app/main.dart';

/// Mở [home] trong app thật (theme, giới hạn cỡ chữ...) với dữ liệu mới,
/// trên màn hình [size] và cỡ chữ hệ thống [textScale]. Trả về dữ liệu
/// để kiểm tra / thao tác.
Future<AppState> pumpApp(
  WidgetTester t,
  Widget home, {
  Size size = const Size(375, 812),
  double textScale = 1,
  bool settle = true,
}) async {
  t.view.physicalSize = size * 3;
  t.view.devicePixelRatio = 3;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(t.view.reset);
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  final app = AppState();
  await t.pumpWidget(
    AppScope(
      state: app,
      child: HoomeApp(home: home),
    ),
  );
  if (settle) {
    await t.pumpAndSettle();
  } else {
    await t.pump(const Duration(milliseconds: 500));
  }
  return app;
}

/// Gỡ app khỏi cây widget (huỷ bộ hẹn giờ / hiệu ứng lặp) trước khi test kết thúc.
Future<void> unmount(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 5));
}

/// Đợi chuyển trang xong khi màn có hiệu ứng chạy mãi (radar, nhấp nháy...)
/// nên không dùng được `pumpAndSettle`. Khung đầu tiên trang mới còn ẩn.
Future<void> pumpRoute(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(seconds: 1));
}

/// Bấm nút ở thanh điều hướng theo tên ("Rooms", "Notifications"...).
Future<void> tapNav(WidgetTester t, String label) async {
  await t.tap(find.byTooltip(label));
  await t.pumpAndSettle();
}
