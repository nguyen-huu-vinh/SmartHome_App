import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome_app/data/app_state.dart';
import 'package:smarthome_app/data/fake_home_api.dart';
import 'package:smarthome_app/data/home_device.dart';
import 'package:smarthome_app/data/sample_data.dart';
import 'package:smarthome_app/main.dart';
import 'package:smarthome_app/screens/auth/login_screen.dart';
import 'package:smarthome_app/screens/auth/signup_screen.dart';
import 'package:smarthome_app/screens/auth/verify_screen.dart';
import 'package:smarthome_app/screens/home/home_screen.dart';
import 'package:smarthome_app/screens/setup/add_devices_screen.dart';
import 'package:smarthome_app/screens/setup/adding_device_screen.dart';
import 'package:smarthome_app/screens/setup/manage_homes_screen.dart';
import 'package:smarthome_app/screens/setup/manage_rooms_screen.dart';
import 'package:smarthome_app/widgets/app_buttons.dart';
import 'package:smarthome_app/widgets/app_tour.dart';
import 'package:smarthome_app/widgets/badges.dart';
import 'package:smarthome_app/widgets/device_controls.dart';
import 'package:smarthome_app/widgets/paged_list.dart';

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

  testWidgets(
    'kéo xuống để làm mới: Home và tab thông báo (danh sách ngắn)',
    (t) async {
      final spinner = find.byWidgetPredicate(
        (w) => w is RefreshProgressIndicator || w is CupertinoActivityIndicator,
      );
      Future<void> pull() async {
        await t.fling(find.byType(ListView).first, const Offset(0, 400), 1000);
        await t.pump();
        await t.pump(const Duration(milliseconds: 300));
        expect(spinner, findsOneWidget);
        await t.pumpAndSettle();
        expect(spinner, findsNothing);
      }

      await pumpApp(t, const HomeScreen());
      await pull();
      await tapNav(t, 'Notifications');
      await pull();
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('phân trang: cuộn tới cuối tải thêm, kéo làm mới về trang đầu', (
    t,
  ) async {
    await pumpApp(
      t,
      Scaffold(
        body: PagedList(
          itemCount: 25,
          pageSize: 10,
          itemBuilder: (_, i) => SizedBox(height: 100, child: Text('Item $i')),
        ),
      ),
    );
    final more = find.bySemanticsLabel('Loading more');
    expect(find.text('Item 0'), findsOneWidget);

    // Trang 1: 0..9. Cuộn xuống cuối → vòng xoay → thêm 10..19.
    Future<void> scrollToEnd() async {
      await t.drag(find.byType(ListView), const Offset(0, -3000));
      await t.pump();
    }

    await scrollToEnd();
    expect(find.text('Item 9'), findsOneWidget);
    expect(find.text('Item 10'), findsNothing);
    expect(more, findsOneWidget);
    await t.pump(const Duration(milliseconds: 700));
    await scrollToEnd();
    expect(find.text('Item 19'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 700));
    await scrollToEnd();
    await t.pumpAndSettle();
    expect(find.text('Item 24'), findsOneWidget);
    expect(more, findsNothing, reason: 'hết dữ liệu thì không tải nữa');

    // Lên đầu, kéo làm mới → chỉ còn trang đầu.
    await t.drag(find.byType(ListView), const Offset(0, 5000));
    await t.pumpAndSettle();
    await t.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await t.pumpAndSettle();
    // Cuộn nhẹ để ListView tính lại chiều dài danh sách đã ngắn đi.
    await t.drag(find.byType(ListView), const Offset(0, -50));
    await t.pumpAndSettle();
    await scrollToEnd();
    expect(find.text('Item 9'), findsOneWidget);
    expect(find.text('Item 10'), findsNothing);
    await unmount(t); // đang tải trang 2 → gỡ màn cho hết hẹn giờ
  });

  testWidgets('thông báo tải từng trang từ server giả', (t) async {
    final app = await pumpApp(
      t,
      const HomeScreen(),
      api: FakeHomeApi(
        alerts: FakeHomeApi.manyAlerts(25),
        delay: Duration.zero,
        failRate: 0,
      ),
    );
    expect(app.alerts, hasLength(10), reason: 'mới tải trang đầu');
    expect(app.alertCount, 25, reason: 'chuông tính tổng số trên server');
    expect(find.text('9+'), findsOneWidget);

    await tapNav(t, 'Notifications');
    for (var i = 0; i < 6 && app.alertsHasMore; i++) {
      await t.drag(find.byType(ListView), const Offset(0, -3000));
      await t.pumpAndSettle();
    }
    expect(app.alerts, hasLength(25));
    expect(app.alertsHasMore, isFalse);

    // Kéo làm mới → về lại trang đầu.
    await app.refreshAlerts();
    expect(app.alerts, hasLength(10));
  });

  testWidgets('mất mạng khi tải thêm → bấm Retry tải lại được', (t) async {
    final api = FakeHomeApi(
      alerts: FakeHomeApi.manyAlerts(25),
      delay: Duration.zero,
      failRate: 0,
    );
    final app = await pumpApp(t, const HomeScreen(), api: api);
    await tapNav(t, 'Notifications');

    api.failRate = 1; // từ giờ mọi lần gọi đều lỗi
    await t.drag(find.byType(ListView), const Offset(0, -3000));
    await t.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(app.alerts, hasLength(10));

    api.failRate = 0; // có mạng lại
    await t.tap(find.text('Retry'));
    await t.pumpAndSettle();
    expect(app.alerts, hasLength(20));
    expect(find.text('Retry'), findsNothing);
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

  testWidgets('lần đầu vào app → giới thiệu 4 bước, xem xong thì nhớ', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await pumpApp(t, const HomeScreen());
    await t.pump(const Duration(seconds: 1)); // chờ màn hiện xong
    await t.pumpAndSettle();
    expect(find.text('Your home'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await t.tap(find.text('Next'));
      await t.pumpAndSettle();
    }
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Skip'), findsNothing, reason: 'bước cuối');
    await t.tap(find.text('Got it'));
    await t.pumpAndSettle();
    expect(find.text('Got it'), findsNothing);
    expect(await AppTour.seen(), isTrue);
  });

  testWidgets('Settings → App Tour mở lại giới thiệu, Skip để tắt', (t) async {
    await pumpApp(t, const HomeScreen());
    expect(find.text('Your home'), findsNothing, reason: 'đã xem rồi');
    await tapNav(t, 'Settings');
    await t.tap(find.text('App Tour'));
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(find.text('Your home'), findsOneWidget);

    await t.tap(find.text('Skip'));
    await t.pumpAndSettle();
    expect(find.text('Your home'), findsNothing);
  });

  testWidgets(
    'Settings → Language → Tiếng Việt: cả app đổi chữ, nhớ lựa chọn',
    (t) async {
      final app = await pumpApp(t, const HomeScreen());
      await tapNav(t, 'Settings');
      await t.tap(find.text('Language'));
      await t.pumpAndSettle();
      await t.tap(find.text('Tiếng Việt'));
      await t.pumpAndSettle();

      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.byTooltip('Trang chủ'), findsOneWidget, reason: 'thanh dưới');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), 'vi');

      // Mở lại app → đọc lựa chọn cũ.
      final again = AppState(api: FakeHomeApi.instant());
      await again.loadLocale();
      expect(again.locale.value, const Locale('vi'));
      expect(app.locale.value, const Locale('vi'));
    },
  );

  testWidgets('gán phòng → Continue: thiết bị được lưu vào nhà, mở Home', (
    t,
  ) async {
    final lamp = SampleData.nearby[0];
    final app = await pumpApp(t, ManageRoomsScreen(devices: [lamp]));
    final before = app.devices.length;
    await t.tap(find.text(lamp.name));
    await t.pumpAndSettle();
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();

    expect(app.devices.length, before + 1);
    expect(app.devices.last.name, lamp.name);
    expect(app.devices.last.room, app.rooms.first.name);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('gán phòng mà mất mạng → ở lại, báo lỗi, bấm lại được', (
    t,
  ) async {
    final api = FakeHomeApi(
      alerts: SampleData.alerts,
      delay: Duration.zero,
      failRate: 0,
    );
    final lamp = SampleData.nearby[0];
    final app = await pumpApp(t, ManageRoomsScreen(devices: [lamp]), api: api);
    final before = app.devices.length;
    await t.tap(find.text(lamp.name));
    await t.pumpAndSettle();

    api.failRate = 1;
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.byType(ManageRoomsScreen), findsOneWidget);
    expect(
      find.text("Couldn't add the devices. Check your connection."),
      findsOneWidget,
    );
    expect(app.devices.length, before);

    api.failRate = 0;
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(app.devices.length, before + 1);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('đăng nhập lại khi đã có nhà → màn nhà hiện các nhà đã tạo', (
    t,
  ) async {
    final api = FakeHomeApi(
      alerts: SampleData.alerts,
      homes: ['Beach House', 'Office'],
      delay: Duration.zero,
      failRate: 0,
    );
    final app = await pumpApp(t, const SizedBox(), api: api);
    expect(app.hasHomes, isTrue, reason: 'nhà đã tải từ server');

    await t.pumpWidget(
      AppScope(
        state: app,
        child: const HoomeApp(home: ManageHomesScreen()),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byType(ManageHomesScreen), findsOneWidget);
    expect(find.text('Beach House'), findsOneWidget);
    expect(find.text('Office'), findsOneWidget);
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
