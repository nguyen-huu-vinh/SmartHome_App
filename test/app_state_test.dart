import 'package:flutter_test/flutter_test.dart';
import 'package:smarthome_app/core/feedback.dart';
import 'package:smarthome_app/core/validators.dart';
import 'package:smarthome_app/data/app_state.dart';
import 'package:smarthome_app/data/home_device.dart';
import 'package:smarthome_app/data/sample_data.dart';
import 'package:smarthome_app/data/user.dart';

void main() {
  late AppState app;
  late int notified;

  setUp(() {
    app = AppState()..addListener(() => notified++);
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

    test('che email, số ít / số nhiều', () {
      expect(maskEmail('wrteam_design@gmail.com'), 'wrteam*****ign@gmail.com');
      expect(maskEmail('ab@c.com'), 'ab@c.com');
      expect(plural(1, 'Device'), '1 Device');
      expect(plural(3, 'Device'), '3 Devices');
    });
  });
}
