import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthome_app/data/home_device.dart';
import 'package:smarthome_app/data/sample_data.dart';
import 'package:smarthome_app/screens/auth/login_screen.dart';
import 'package:smarthome_app/screens/auth/signup_screen.dart';
import 'package:smarthome_app/screens/auth/verify_screen.dart';
import 'package:smarthome_app/screens/home/home_screen.dart';
import 'package:smarthome_app/screens/setup/add_devices_screen.dart';
import 'package:smarthome_app/screens/setup/adding_device_screen.dart';
import 'package:smarthome_app/screens/setup/manage_homes_screen.dart';
import 'package:smarthome_app/screens/setup/manage_rooms_screen.dart';
import 'package:smarthome_app/widgets/app_buttons.dart';
import 'package:smarthome_app/widgets/badges.dart';
import 'package:smarthome_app/widgets/device_controls.dart';

import 'helpers.dart';

// Các luồng chính của người dùng — chạy `flutter test` sau mỗi lần sửa.

void main() {
  testWidgets('bật đèn trong bảng chi tiết → thẻ ở Home cập nhật theo', (
    t,
  ) async {
    final app = await pumpApp(t, const HomeScreen());
    final lamp = app.devices.first; // Plueto Smart L30, đang tắt
    expect(app.isOn(lamp), isFalse);

    // Thẻ nổi bật đầu tiên cũng là đèn này → bấm tên ở thẻ đèn bên dưới.
    await t.tap(find.text(lamp.name).last);
    await t.pumpAndSettle();
    await t.tap(find.byType(PowerBox));
    await t.pumpAndSettle();
    expect(app.isOn(lamp), isTrue);

    await t.tap(find.byTooltip('Close'));
    await t.pumpAndSettle();
    final cards = t.widgetList<VerticalSwitch>(find.byType(VerticalSwitch));
    expect(cards.first.on, isTrue);
  });

  testWidgets('xoá phòng ở tab Rooms rồi hoàn tác', (t) async {
    final app = await pumpApp(t, const HomeScreen());
    await tapNav(t, 'Rooms');
    await t.tap(find.text('Manage'));
    await t.pumpAndSettle();

    final kitchen = app.rooms[1];
    await t.tap(
      find.byWidgetPredicate(
        (w) => w is RemoveBadge && w.label == 'Remove ${kitchen.name}',
      ),
    );
    await t.pumpAndSettle();
    expect(app.rooms, isNot(contains(kitchen)));
    expect(find.text('${kitchen.name} removed'), findsOneWidget);

    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(app.rooms[1], kitchen);
  });

  testWidgets('vuốt ẩn thông báo → số trên chuông giảm, hoàn tác được', (
    t,
  ) async {
    final app = await pumpApp(t, const HomeScreen());
    await tapNav(t, 'Notifications');
    expect(find.text('3'), findsOneWidget);

    final first = app.alerts.first;
    await t.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await t.pumpAndSettle();
    expect(app.alerts, isNot(contains(first)));
    expect(find.text('2'), findsOneWidget);

    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(app.alerts.first, first);
  });

  testWidgets('Re-Connect thành công → thông báo biến mất', (t) async {
    final app = await pumpApp(t, const HomeScreen());
    await tapNav(t, 'Notifications');
    final count = app.alerts.length;

    await t.tap(find.text('Re-Connect').first);
    await t.pump(const Duration(milliseconds: 1600));
    await t.pumpAndSettle();
    expect(app.alerts, hasLength(count - 1));
    expect(find.text('Re-connected successfully'), findsOneWidget);
  });

  testWidgets('gợi ý tắt đèn: nút nguồn tắt cả dãy đèn phòng khách', (t) async {
    final app = await pumpApp(t, const HomeScreen());
    await tapNav(t, 'Notifications');
    final hall = app.inRoom('Main Hall')
      ..retainWhere((d) => d.group == DeviceGroup.lights);
    expect(hall.any(app.isOn), isTrue);

    await t.tap(find.byType(PowerBox));
    await t.pumpAndSettle();
    expect(hall.any(app.isOn), isFalse);
  });

  testWidgets('sửa hồ sơ → tên mới hiện ở Settings', (t) async {
    final app = await pumpApp(t, const HomeScreen());
    await tapNav(t, 'Settings');
    await t.tap(find.text(app.profile.name));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextField).first, 'Lan Anh');
    await t.tap(find.text('Update'));
    await t.pumpAndSettle();
    expect(app.profile.name, 'Lan Anh');
    expect(find.text('Lan Anh'), findsOneWidget);
    expect(find.text('Profile updated'), findsOneWidget);
  });

  testWidgets('tìm không thấy → bấm Home để về trạng thái ban đầu', (t) async {
    await pumpApp(t, const HomeScreen());
    await t.enterText(find.byType(TextField), 'zzz');
    await t.pumpAndSettle();
    expect(find.text('No devices found'), findsOneWidget);

    await tapNav(t, 'Home');
    expect(find.text('No devices found'), findsNothing);
  });

  testWidgets('đăng ký → nhập mã → tạo nhà; hồ sơ lưu theo thông tin mới', (
    t,
  ) async {
    final app = await pumpApp(t, const SignupScreen());
    final fields = find.byType(TextField);
    await t.enterText(fields.at(0), 'Lan Anh');
    await t.enterText(fields.at(1), '0912345678');
    await t.enterText(fields.at(2), 'lan@hoome.app');
    await t.enterText(fields.at(3), 'secret');
    await t.pump(); // nút Continue vẽ lại ở trạng thái bấm được
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(app.profile.name, 'Lan Anh');
    expect(find.byType(VerifyScreen), findsOneWidget);

    await t.enterText(find.byType(TextField), '123456');
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.text('Create Home'), findsOneWidget);
    await unmount(t);
  });

  testWidgets('tạo nhà → quét → kết nối (thử lại máy lỗi) → gán phòng → Home', (
    t,
  ) async {
    final app = await pumpApp(t, const ManageHomesScreen());
    await t.tap(find.text('Add Home'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'Beach House');
    await t.tap(find.text('Continue'));
    await pumpRoute(t);
    expect(app.homes, ['Beach House']);
    expect(
      find.text('Beach House'),
      findsOneWidget,
      reason: 'tên nhà ở đầu trang',
    );

    // Radar quay mãi → dùng pump theo thời gian thay vì pumpAndSettle.
    await t.tap(find.text('Allow and Continue'));
    await t.pump(const Duration(seconds: 4));
    await t.tap(find.text('Allow and Continue'));
    await t.pump(const Duration(seconds: 12));
    expect(find.text('Unable to connect'), findsOneWidget);
    await t.tap(find.byTooltip('Retry'));
    await t.pump(const Duration(seconds: 2));
    await t.pump(const Duration(seconds: 1)); // chữ trạng thái cũ mờ hẳn
    expect(find.text('Unable to connect'), findsNothing);
    expect(find.text('Connected'), findsNWidgets(SampleData.nearby.length));

    await t.tap(find.text('Continue'));
    await pumpRoute(t);
    expect(find.byType(ManageRoomsScreen), findsOneWidget);
    await t.tap(find.text(SampleData.nearby.first.name));
    await t.pump();
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('thêm thiết bị thủ công → ghép nối → gán phòng', (t) async {
    await pumpApp(t, const AddDevicesScreen());
    await t.tap(find.text('Camera'));
    await t.pumpAndSettle();
    await t.tap(find.text('Tapo C201 360°'));
    await t.tap(find.text('Tapo C301 180°'));
    await t.pump();
    await t.tap(find.text('Add (2)'));
    await pumpRoute(t);
    expect(find.byType(AddingDeviceScreen), findsOneWidget);

    // 2 thiết bị × 3 bước, mỗi bước 1,2 giây → sang màn gán phòng.
    await t.pump(const Duration(seconds: 8));
    await t.pumpAndSettle();
    expect(find.byType(ManageRoomsScreen), findsOneWidget);
    expect(find.byType(AddingDeviceScreen), findsNothing);
  });

  testWidgets('đăng nhập: Continue chỉ bấm được khi email + mật khẩu hợp lệ', (
    t,
  ) async {
    await pumpApp(t, const LoginScreen());
    bool enabled() =>
        t.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed != null;
    expect(enabled(), isFalse);

    await t.enterText(find.byType(TextField).at(0), 'me@hoome');
    await t.enterText(find.byType(TextField).at(1), 'secret');
    await t.pump();
    expect(enabled(), isFalse, reason: 'email chưa hợp lệ');

    await t.enterText(find.byType(TextField).at(0), 'me@hoome.app');
    await t.pump();
    expect(enabled(), isTrue);
  });
}
