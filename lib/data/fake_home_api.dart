import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'activity_alert.dart';
import 'home_api.dart';
import 'home_device.dart';
import 'room.dart';
import 'sample_data.dart';

/// "Server giả" khi chưa có backend: dữ liệu khởi đầu lấy từ [SampleData]
/// nhưng trả về y như API thật — chờ mạng, chia trang, thỉnh thoảng lỗi.
///
/// [persist] = true → nhớ những gì đã đổi (nhà, phòng, thiết bị) vào máy,
/// tắt app mở lại vẫn còn. Mặc định chỉ nhớ trong bộ nhớ (cho test).
class FakeHomeApi implements HomeApi {
  FakeHomeApi({
    List<ActivityAlert>? alerts,
    List<Room>? rooms,
    List<HomeDevice>? devices,
    List<String>? homes,
    this.delay,
    this.failRate = 0.1,
    this.persist = false,
    Random? random,
  }) : _alerts = alerts ?? manyAlerts(35),
       _rooms = [...(rooms ?? SampleData.rooms)],
       _devices = [...(devices ?? SampleData.devices)],
       _homes = [...(homes ?? const [])],
       _random = random ?? Random();

  /// Dùng trong test: 3 thông báo mẫu, trả ngay, không bao giờ lỗi.
  FakeHomeApi.instant()
    : this(alerts: SampleData.alerts, delay: Duration.zero, failRate: 0);

  final List<ActivityAlert> _alerts;
  final Random _random;

  /// "Bảng" của server: nhà, phòng, thiết bị.
  final List<String> _homes;
  final List<Room> _rooms;
  final List<HomeDevice> _devices;

  /// Thời gian chờ mỗi lần gọi; null → ngẫu nhiên 0,5–1,5 giây.
  final Duration? delay;

  /// Tỉ lệ gọi bị lỗi: 0 → không bao giờ, 1 → luôn lỗi.
  double failRate;

  final bool persist;

  static const _homesKey = 'fake_api.homes';
  static const _roomsKey = 'fake_api.rooms';
  static const _devicesKey = 'fake_api.devices';

  /// Đọc sổ đã lưu trong máy (chỉ 1 lần). Chưa lưu gì → giữ dữ liệu mẫu.
  late final Future<void> _loaded = _read();

  Future<void> _read() async {
    if (!persist) return;
    final prefs = await SharedPreferences.getInstance();
    List<T>? list<T>(String key, T Function(Map<String, Object?>) parse) {
      final text = prefs.getString(key);
      if (text == null) return null;
      return [
        for (final item in jsonDecode(text) as List<Object?>)
          parse(Map<String, Object?>.from(item! as Map)),
      ];
    }

    if (prefs.getStringList(_homesKey) case final homes?) {
      _homes
        ..clear()
        ..addAll(homes);
    }
    if (list(_roomsKey, Room.fromJson) case final rooms?) {
      _rooms
        ..clear()
        ..addAll(rooms);
    }
    if (list(_devicesKey, HomeDevice.fromJson) case final devices?) {
      _devices
        ..clear()
        ..addAll(devices);
    }
  }

  Future<void> _save() async {
    if (!persist) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_homesKey, _homes);
    await prefs.setString(
      _roomsKey,
      jsonEncode([for (final r in _rooms) r.toJson()]),
    );
    await prefs.setString(
      _devicesKey,
      jsonEncode([for (final d in _devices) d.toJson()]),
    );
  }

  /// Giả mạng: chờ một lúc, thỉnh thoảng lỗi.
  Future<void> _network() async {
    final wait = delay ?? Duration(milliseconds: 500 + _random.nextInt(1000));
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    if (_random.nextDouble() < failRate) {
      throw const ApiException('No internet connection');
    }
  }

  @override
  Future<PageResult<ActivityAlert>> fetchAlerts({
    required int page,
    required int size,
  }) async {
    await _network();
    // Giống LIMIT/OFFSET ở backend.
    final start = page * size;
    return PageResult(
      items: _alerts.skip(start).take(size).toList(),
      total: _alerts.length,
      hasMore: start + size < _alerts.length,
    );
  }

  // ───────────── Nhà ─────────────

  @override
  Future<List<String>> fetchHomes() async {
    await _network();
    await _loaded;
    return [..._homes];
  }

  @override
  Future<void> saveHomes(List<String> homes) async {
    await _network();
    await _loaded;
    _homes
      ..clear()
      ..addAll(homes);
    await _save();
  }

  // ───────────── Phòng ─────────────

  @override
  Future<List<Room>> fetchRooms() async {
    await _network();
    await _loaded;
    return [..._rooms];
  }

  @override
  Future<void> addRoom(Room room, {int? index}) async {
    await _network();
    await _loaded;
    if (_rooms.contains(room)) return;
    _rooms.insert((index ?? _rooms.length).clamp(0, _rooms.length), room);
    await _save();
  }

  @override
  Future<void> removeRoom(Room room) async {
    await _network();
    await _loaded;
    _rooms.remove(room);
    await _save();
  }

  // ───────────── Thiết bị ─────────────

  @override
  Future<List<HomeDevice>> fetchDevices() async {
    await _network();
    await _loaded;
    return [..._devices];
  }

  @override
  Future<List<HomeDevice>> addDevices(List<HomeDevice> devices) async {
    await _network();
    await _loaded;
    final saved = <HomeDevice>[];
    for (final d in devices) {
      // Server đặt mã: cùng mẫu, cùng phòng → "…#2", "…#3".
      var id = d.id;
      for (var n = 2; _devices.any((x) => x.id == id); n++) {
        id = '${d.id}#$n';
      }
      final device = d.copyWith(id: id);
      _devices.add(device);
      saved.add(device);
    }
    await _save();
    return saved;
  }

  @override
  Future<void> setDeviceOn(HomeDevice device, bool on) async {
    await _network();
    await _loaded;
    final i = _devices.indexWhere((x) => x.id == device.id);
    if (i >= 0) _devices[i] = _devices[i].copyWith(on: on);
    await _save();
  }

  /// [count] thông báo khác nhau tạo từ các thông báo mẫu, cũ dần
  /// (để thử danh sách dài).
  static List<ActivityAlert> manyAlerts(int count) => List.generate(count, (i) {
    final a = SampleData.alerts[i % SampleData.alerts.length];
    return ActivityAlert(
      kind: a.kind,
      title: a.title,
      message: a.message,
      image: a.image,
      room: a.room,
      age: a.age + Duration(hours: 3 * i),
    );
  });
}
