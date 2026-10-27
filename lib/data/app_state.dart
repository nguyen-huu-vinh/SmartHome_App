import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'activity_alert.dart';
import 'device_settings.dart';
import 'home_device.dart';
import 'room.dart';
import 'sample_data.dart';
import 'user.dart';

/// Toàn bộ dữ liệu dùng chung khi app đang chạy: hồ sơ, tuỳ chọn, nhà,
/// phòng, thiết bị (bật/tắt + cài đặt riêng), thông báo.
///
/// - Màn hình đọc qua `AppScope.of(context)` → tự vẽ lại khi dữ liệu đổi,
///   không cần truyền dữ liệu qua từng màn.
/// - Mọi thay đổi đi qua các hàm ở đây (danh sách trả ra chỉ để đọc).
/// - Hiện lấy từ [SampleData] và chỉ giữ trong bộ nhớ. Khi có API hoặc cần
///   lưu xuống máy, chỉ cần sửa lớp này.
class AppState extends ChangeNotifier {
  AppState({
    List<HomeDevice> devices = SampleData.devices,
    List<Room> rooms = SampleData.rooms,
    List<ActivityAlert> alerts = SampleData.alerts,
  }) : devices = UnmodifiableListView(devices),
       _rooms = [...rooms],
       _alerts = [...alerts],
       _on = {for (final d in devices) d: d.on};

  // ───────────────────────── Hồ sơ & tuỳ chọn ─────────────────────────

  Profile _profile = SampleData.profile;
  Profile get profile => _profile;

  void updateProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  final _prefs = {for (final p in Preference.values) p: p.initial};

  bool pref(Preference p) => _prefs[p]!;

  void setPref(Preference p, bool value) {
    _prefs[p] = value;
    notifyListeners();
  }

  // ───────────────────────── Nhà ─────────────────────────

  List<String> _homes = const [];
  int _homeIndex = 0;

  /// Người dùng đã tự tạo ít nhất 1 nhà.
  bool get hasHomes => _homes.isNotEmpty;

  /// Tên các nhà; chưa tạo nhà nào → 1 nhà mặc định.
  List<String> get homes => hasHomes ? _homes : const ['My Home'];

  /// Nhà đang chọn (vị trí trong [homes]).
  int get homeIndex => _homeIndex.clamp(0, homes.length - 1);

  void setHomes(List<String> homes, {int index = 0}) {
    _homes = List.unmodifiable(homes);
    _homeIndex = index;
    notifyListeners();
  }

  void selectHome(int index) {
    _homeIndex = index;
    notifyListeners();
  }

  // ───────────────────────── Phòng ─────────────────────────

  final List<Room> _rooms;
  List<Room> get rooms => UnmodifiableListView(_rooms);

  /// Phải còn ít nhất 1 phòng.
  bool get canRemoveRoom => _rooms.length > 1;

  /// Phòng theo tên (thiết bị gắn phòng bằng tên); không thấy → phòng mặc định.
  Room roomNamed(String name) =>
      _rooms.firstWhere((r) => r.name == name, orElse: () => Room(name: name));

  void addRoom(Room room) {
    _rooms.add(room);
    notifyListeners();
  }

  /// Xoá [room]. Trả về vị trí cũ để hoàn tác bằng [insertRoom];
  /// null = không xoá (không có phòng này, hoặc là phòng cuối cùng).
  int? removeRoom(Room room) {
    final i = _rooms.indexOf(room);
    if (i < 0 || !canRemoveRoom) return null;
    _rooms.removeAt(i);
    notifyListeners();
    return i;
  }

  void insertRoom(int index, Room room) {
    _rooms.insert(index.clamp(0, _rooms.length), room);
    notifyListeners();
  }

  // ───────────────────────── Thiết bị ─────────────────────────

  final List<HomeDevice> devices;
  final Map<HomeDevice, bool> _on;

  bool isOn(HomeDevice d) => _on[d] ?? false;

  void setOn(HomeDevice d, bool on) => setAllOn([d], on);

  void toggle(HomeDevice d) => setOn(d, !isOn(d));

  /// Bật/tắt nhiều thiết bị cùng lúc (VD: cả dãy đèn 1 phòng).
  void setAllOn(Iterable<HomeDevice> list, bool on) {
    var changed = false;
    for (final d in list) {
      if (isOn(d) == on) continue;
      _on[d] = on;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  List<HomeDevice> inRoom(String room) => [
    for (final d in devices)
      if (d.room == room) d,
  ];

  List<HomeDevice> inGroup(DeviceGroup group) => [
    for (final d in devices)
      if (d.group == group) d,
  ];

  int countIn(Room room) => devices.where((d) => d.room == room.name).length;

  /// Các máy cùng mẫu với [d] (cùng nhóm, cùng tên) ở mọi phòng,
  /// xếp theo thứ tự phòng.
  List<HomeDevice> unitsOf(HomeDevice d) {
    int order(HomeDevice x) {
      final i = _rooms.indexWhere((r) => r.name == x.room);
      return i < 0 ? _rooms.length : i;
    }

    return [
      for (final x in devices)
        if (_sameModel(x, d)) x,
    ]..sort((a, b) => order(a).compareTo(order(b)));
  }

  /// Cùng mẫu có ở nhiều phòng → thẻ hiện tên phòng để phân biệt.
  bool isMultiRoom(HomeDevice d) =>
      devices.where((x) => _sameModel(x, d)).length > 1;

  static bool _sameModel(HomeDevice a, HomeDevice b) =>
      a.group == b.group && a.name == b.name;

  // ───────────────────── Cài đặt riêng từng thiết bị ─────────────────────

  final _lights = <HomeDevice, LightSettings>{};
  final _acs = <HomeDevice, AcSettings>{};
  final _cameras = <HomeDevice, CameraSettings>{};
  final _cleaners = <HomeDevice, CleanerSettings>{};

  LightSettings light(HomeDevice d) =>
      _lights.putIfAbsent(d, LightSettings.new);
  AcSettings ac(HomeDevice d) => _acs.putIfAbsent(d, AcSettings.new);
  CameraSettings camera(HomeDevice d) =>
      _cameras.putIfAbsent(d, CameraSettings.new);
  CleanerSettings cleaner(HomeDevice d) =>
      _cleaners.putIfAbsent(d, CleanerSettings.new);

  /// Đổi cài đặt rồi báo các màn vẽ lại.
  /// VD: `app.update(() => app.ac(d).setTemp(24))`.
  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  // ───────────────────────── Thông báo ─────────────────────────

  final List<ActivityAlert> _alerts;
  List<ActivityAlert> get alerts => UnmodifiableListView(_alerts);

  /// Ẩn [alert]. Trả về vị trí cũ để hoàn tác bằng [restoreAlert].
  int? dismissAlert(ActivityAlert alert) {
    final i = _alerts.indexOf(alert);
    if (i < 0) return null;
    _alerts.removeAt(i);
    notifyListeners();
    return i;
  }

  void restoreAlert(int index, ActivityAlert alert) {
    _alerts.insert(index.clamp(0, _alerts.length), alert);
    notifyListeners();
  }
}

/// Đưa [AppState] tới mọi màn. Đặt trên cùng, bọc cả `MaterialApp`
/// (để các bảng trượt, hộp thoại cũng đọc được).
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  /// Dùng trong `build`: lấy dữ liệu và tự vẽ lại khi dữ liệu đổi.
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Dùng trong hàm xử lý sự kiện: chỉ lấy dữ liệu, không đăng ký vẽ lại.
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
