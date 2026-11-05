import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome_app/core/validators.dart';
import 'package:smarthome_app/data/app_state.dart';
import 'package:smarthome_app/data/fake_home_api.dart';
import 'package:smarthome_app/data/home_api.dart';
import 'package:smarthome_app/data/home_device.dart';
import 'package:smarthome_app/data/room.dart';
import 'package:smarthome_app/data/sample_data.dart';
import 'package:smarthome_app/data/user.dart';
import 'package:smarthome_app/l10n/l10n.dart';

void main() {
  late AppState app;
  late int notified;

  setUp(() async {
    app = AppState(api: FakeHomeApi.instant());
    await app.loadMoreAlerts(); // trang thông báo đầu tiên
    app.addListener(() => notified++);
    notified = 0;
  });

  HomeDevice named(String name, {String? room}) => app.devices.firstWhere(
    (d) => d.name == name && (room == null || d.room == room),
  );

  group('thiết bị', () {
    test('bật/tắt đổi trạng thái và báo vẽ lại', () {
      final lamp = named('Plueto Smart L30');
      expect(app.isOn(lamp), isFalse);
      app.toggle(lamp);
      expect(app.isOn(lamp), isTrue);
      expect(notified, 1);
    });

    test('setAllOn chỉ báo khi có thay đổi', () {
      final lights = app.inRoom('Main Hall')
        ..retainWhere((d) => d.group == DeviceGroup.lights);
      app.setAllOn(lights, false);
      expect(lights.any(app.isOn), isFalse);
      expect(notified, 1);
      app.setAllOn(lights, false);
      expect(notified, 1);
    });

    test('server lỗi → công tắc trở về như cũ và báo lỗi', () async {
      final api = FakeHomeApi(delay: Duration.zero, failRate: 1);
      final app = AppState(api: api);
      final errors = <AppError>[];
      app.errors.listen(errors.add);
      final lamp = named('Plueto Smart L30');
      final done = app.toggle(lamp);
      expect(app.isOn(lamp), isTrue, reason: 'đổi ngay, chưa chờ server');
      await done;
      expect(app.isOn(lamp), isFalse);
      await pumpEventQueue();
      expect(errors, [const SwitchError(device: 'Plueto Smart L30', on: true)]);
    });

    test('bấm liền 2 lần, cả 2 đều lỗi → về trạng thái ban đầu', () async {
      final app = AppState(
        api: FakeHomeApi(delay: const Duration(milliseconds: 10), failRate: 1),
      );
      final lamp = named('Plueto Smart L30');
      final first = app.setOn(lamp, true);
      final second = app.setOn(lamp, false);
      final third = app.setOn(lamp, true);
      await Future.wait([first, second, third]);
      expect(app.isOn(lamp), isFalse);
    });

    test('lần bấm trước thành công về muộn → công tắc theo server', () async {
      final api = _ScriptedApi([
        (wait: 50, fail: false), // bật: chậm, thành công
        (wait: 10, fail: true), // tắt: nhanh, lỗi
      ]);
      final app = AppState(api: api);
      final lamp = named('Plueto Smart L30');
      await Future.wait([app.setOn(lamp, true), app.setOn(lamp, false)]);
      expect(api.deviceOn[lamp.id], isTrue);
      expect(app.isOn(lamp), isTrue, reason: 'khớp với server');
    });

    test(
      'đang tải trạng thái mà bấm công tắc → không bị dữ liệu cũ đè',
      () async {
        final api = _ScriptedApi([(wait: 10, fail: false)], fetchWait: 50);
        final app = AppState(api: api);
        final lamp = named('Plueto Smart L30');
        final load = app.loadDevices(); // server: đèn tắt
        await app.setOn(lamp, true); // bật xong trước khi tải xong
        await load;
        expect(app.isOn(lamp), isTrue);

        // Lần sau lỗi → về đúng trạng thái server (bật), không phải "tắt" cũ.
        api.steps.add((wait: 0, fail: true));
        await app.setOn(lamp, false);
        expect(app.isOn(lamp), isTrue);
      },
    );

    testWidgets('mở app mà mạng lỗi → tự thử lại', (t) async {
      final api = FakeHomeApi(
        devices: [
          for (final d in SampleData.devices)
            d.name == 'Plueto Smart L30' ? d.copyWith(on: true) : d,
        ],
        delay: Duration.zero,
        failRate: 1,
      );
      final app = AppState(api: api);
      final lamp = named('Plueto Smart L30');
      await t.pump();
      expect(app.isOn(lamp), isFalse, reason: 'lần đầu lỗi');
      api.failRate = 0;
      await t.pump(const Duration(seconds: 1)); // thử lại lần 2
      await t.runAsync(() => Future<void>.delayed(Duration.zero));
      await t.pump();
      expect(app.isOn(lamp), isTrue);
    });

    test('nhớ trạng thái vào máy: mở app lần sau vẫn còn', () async {
      SharedPreferences.setMockInitialValues({});
      FakeHomeApi server() =>
          FakeHomeApi(delay: Duration.zero, failRate: 0, persist: true);
      final first = AppState(api: server());
      final lamp = named('Plueto Smart L30');
      await first.setOn(lamp, true);

      final second = AppState(api: server()); // "mở lại app"
      expect(second.isOn(lamp), isFalse, reason: 'chưa tải xong');
      await second.loadDevices();
      expect(second.isOn(lamp), isTrue);
    });

    test(
      'thêm thiết bị: có mã riêng, 2 máy cùng mẫu cùng phòng vẫn khác nhau',
      () async {
        final cam = SampleData.nearby[1];
        HomeDevice made() => HomeDevice(
          name: cam.name,
          image: cam.image,
          group: cam.group,
          room: 'Bedroom',
        );
        final before = app.devices.length;
        final inBedroom = app.countIn(app.rooms[2]);
        await app.addDevices([made(), made()]);
        expect(app.devices.length, before + 2);
        final added = app.devices.skip(before).toList();
        expect(added.map((d) => d.id).toSet().length, 2);
        expect(app.countIn(app.rooms[2]), inBedroom + 2);
        app.toggle(added.first);
        expect(app.isOn(added.first), isTrue);
        expect(
          app.isOn(added.last),
          isFalse,
          reason: 'bật 1 máy, máy kia giữ nguyên',
        );
      },
    );

    test('thêm thiết bị mà server lỗi → ném lỗi, không thêm gì', () async {
      final app = AppState(api: FakeHomeApi(delay: Duration.zero, failRate: 1));
      final before = app.devices.length;
      await expectLater(
        app.addDevices([
          HomeDevice(
            name: 'X',
            image: '',
            group: DeviceGroup.lights,
            room: 'Bedroom',
          ),
        ]),
        throwsA(isA<ApiException>()),
      );
      expect(app.devices.length, before);
    });

    test('thêm phòng: hiện ngay; trùng tên thì không thêm', () async {
      final before = app.rooms.length;
      final done = app.addRoom(const Room(name: 'Garage'));
      expect(
        app.rooms.length,
        before + 1,
        reason: 'hiện ngay, chưa chờ server',
      );
      await done;
      expect(app.hasRoom('  garage '), isTrue);
      await app.addRoom(const Room(name: 'GARAGE'));
      expect(app.rooms.length, before + 1);
    });

    test('thêm phòng mà server lỗi → phòng biến mất và báo lỗi', () async {
      final app = AppState(api: FakeHomeApi(delay: Duration.zero, failRate: 1));
      final errors = <AppError>[];
      app.errors.listen(errors.add);
      final before = app.rooms.length;
      await app.addRoom(const Room(name: 'Garage'));
      expect(app.rooms.length, before);
      await pumpEventQueue();
      expect(errors, [const SaveError(SaveKind.addRoom)]);
    });

    test('xoá phòng rồi hoàn tác → về đúng vị trí cũ trên server', () async {
      final api = FakeHomeApi.instant();
      final app = AppState(api: api);
      final kitchen = app.rooms[1];
      final i = app.removeRoom(kitchen)!;
      await pumpEventQueue();
      expect((await api.fetchRooms()).contains(kitchen), isFalse);
      app.insertRoom(i, kitchen);
      await pumpEventQueue();
      expect((await api.fetchRooms()).indexOf(kitchen), 1);
    });

    test(
      'thêm nhà: lưu lên server; lỗi → về danh sách cũ và báo lỗi',
      () async {
        final api = FakeHomeApi(delay: Duration.zero, failRate: 0);
        final app = AppState(api: api);
        app.setHomes(['Home A', 'Home B'], index: 1);
        expect(app.homes, ['Home A', 'Home B']);
        await pumpEventQueue();
        expect(await api.fetchHomes(), ['Home A', 'Home B']);

        final errors = <AppError>[];
        app.errors.listen(errors.add);
        api.failRate = 1;
        app.setHomes(['Home A', 'Home B', 'Home C'], index: 2);
        expect(app.homes.length, 3);
        await pumpEventQueue();
        expect(app.homes, ['Home A', 'Home B']);
        expect(app.homeIndex, 1);
        expect(errors, [const SaveError(SaveKind.saveHomes)]);
      },
    );

    test('nhà, phòng, thiết bị nhớ vào máy: mở app lần sau vẫn còn', () async {
      SharedPreferences.setMockInitialValues({});
      AppState open() => AppState(
        api: FakeHomeApi(delay: Duration.zero, failRate: 0, persist: true),
      );
      final first = open();
      first.setHomes(['Beach House']);
      await first.addRoom(const Room(name: 'Garage', icon: Icons.bed_rounded));
      await first.addDevices([
        HomeDevice(
          name: 'Philips Pendant Lamp',
          image: 'assets/images/devices/lamp.png',
          group: DeviceGroup.lights,
          room: 'Garage',
        ),
      ]);
      await pumpEventQueue();

      final second = open(); // "mở lại app"
      await pumpEventQueue();
      expect(second.homes, ['Beach House']);
      final garage = second.rooms.last;
      expect(garage.name, 'Garage');
      expect(garage.icon, Icons.bed_rounded);
      expect(second.inRoom('Garage').single.name, 'Philips Pendant Lamp');
    });

    test('gom máy cùng mẫu theo thứ tự phòng', () {
      final ac = named('Samsungva AC', room: 'Bedroom');
      final units = app.unitsOf(ac);
      expect(units.map((d) => d.room), ['Main Hall', 'Kitchen', 'Bedroom']);
      expect(app.isMultiRoom(ac), isTrue);
      expect(app.isMultiRoom(named('Luna Smart Fridge')), isFalse);
    });

    test('cài đặt riêng từng máy, update() báo vẽ lại', () {
      final a = named('Samsungva AC', room: 'Main Hall');
      final b = named('Samsungva AC', room: 'Kitchen');
      app.update(() => app.ac(a).setTemp(99));
      expect(app.ac(a).temp, 30, reason: 'giới hạn tối đa');
      expect(app.ac(b).temp, 21, reason: 'máy khác không đổi');
      expect(notified, 1);
    });
  });

  group('phòng', () {
    test('xoá rồi hoàn tác về đúng vị trí', () {
      final kitchen = app.rooms[1];
      final i = app.removeRoom(kitchen);
      expect(i, 1);
      expect(app.rooms, isNot(contains(kitchen)));
      app.insertRoom(i!, kitchen);
      expect(app.rooms[1], kitchen);
    });

    test('không xoá được phòng cuối cùng', () {
      while (app.canRemoveRoom) {
        app.removeRoom(app.rooms.last);
      }
      expect(app.rooms, hasLength(1));
      expect(app.removeRoom(app.rooms.first), isNull);
    });

    test('đếm thiết bị theo phòng', () {
      expect(app.countIn(SampleData.rooms[1]), 9);
      expect(app.roomNamed('Kitchen').color, SampleData.rooms[1].color);
      expect(app.roomNamed('Garage').name, 'Garage');
    });
  });

  group('nhà, hồ sơ, tuỳ chọn, thông báo', () {
    test('chưa tạo nhà → 1 nhà mặc định', () {
      expect(app.hasHomes, isFalse);
      expect(app.homes, ['My Home']);
      app.setHomes(['A', 'B'], index: 1);
      expect(app.homes, ['A', 'B']);
      expect(app.homeIndex, 1);
    });

    test('sửa hồ sơ và tuỳ chọn', () {
      app.updateProfile(app.profile.copyWith(name: 'Lan'));
      expect(app.profile.name, 'Lan');
      expect(app.profile.email, SampleData.profile.email);
      app.setPref(Preference.notifications, true);
      expect(app.pref(Preference.notifications), isTrue);
    });

    test('ẩn thông báo rồi hoàn tác', () {
      final first = app.alerts.first;
      final i = app.dismissAlert(first);
      expect(app.alerts, isNot(contains(first)));
      app.restoreAlert(i!, first);
      expect(app.alerts.first, first);
    });
  });

  group('tiện ích', () {
    test('kiểm tra email / số điện thoại', () {
      expect(isValidEmail('a@b.co'), isTrue);
      expect(isValidEmail(' a@b.co '), isTrue);
      expect(isValidEmail('a@b'), isFalse);
      expect(isValidEmail('ab.co'), isFalse);
      expect(isValidPhone('2625832131'), isTrue);
      expect(isValidPhone('123'), isFalse);
    });

    test('che email', () {
      expect(maskEmail('wrteam_design@gmail.com'), 'wrteam*****ign@gmail.com');
      expect(maskEmail('ab@c.com'), 'ab@c.com');
    });

    test('số ít / số nhiều theo ngôn ngữ', () {
      final en = lookupAppLocalizations(const Locale('en'));
      final vi = lookupAppLocalizations(const Locale('vi'));
      expect(en.devicesCount(1), '1 Device');
      expect(en.devicesCount(3), '3 Devices');
      expect(vi.devicesCount(1), '1 thiết bị');
      expect(vi.devicesCount(3), '3 thiết bị');
    });
  });
}

/// Server giả theo kịch bản: lần gọi bật/tắt thứ i chờ `steps[i].wait` ms,
/// rồi thành công hoặc lỗi. Tải trạng thái chờ [fetchWait] ms.
class _ScriptedApi extends FakeHomeApi {
  _ScriptedApi(this.steps, {this.fetchWait = 0})
    : super(alerts: SampleData.alerts, delay: Duration.zero, failRate: 0);

  final List<({int wait, bool fail})> steps;
  final int fetchWait;
  final deviceOn = <String, bool>{};
  var _call = 0;

  @override
  Future<List<HomeDevice>> fetchDevices() async {
    final snapshot = [
      for (final d in SampleData.devices)
        d.copyWith(on: deviceOn[d.id] ?? d.on),
    ];
    await Future<void>.delayed(Duration(milliseconds: fetchWait));
    return snapshot;
  }

  @override
  Future<void> setDeviceOn(HomeDevice device, bool on) async {
    final step = steps[_call++];
    await Future<void>.delayed(Duration(milliseconds: step.wait));
    if (step.fail) throw const ApiException('No internet connection');
    deviceOn[device.id] = on;
  }
}
