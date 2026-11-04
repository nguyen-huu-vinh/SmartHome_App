import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'activity_alert.dart';
import 'device_settings.dart';
import 'fake_home_api.dart';
import 'home_api.dart';
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
/// - Thông báo tải từng trang qua [api] (hiện là [FakeHomeApi]). Thiết bị,
///   phòng... vẫn lấy từ [SampleData] và chỉ giữ trong bộ nhớ.
class AppState extends ChangeNotifier {
  AppState({
    List<HomeDevice> devices = SampleData.devices,
    List<Room> rooms = SampleData.rooms,
    HomeApi? api,
  }) : api = api ?? FakeHomeApi(),
       devices = UnmodifiableListView(devices),
       _rooms = [...rooms],
       _on = {for (final d in devices) d: d.on} {
    // Tải sẵn trang đầu để chuông có số ngay. Lỗi thì tab thông báo tự thử lại.
    loadMoreAlerts().ignore();
  }

  /// Nơi lấy dữ liệu (server thật hoặc giả).
  final HomeApi api;

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

  static const alertPageSize = 10;

  final _alerts = <ActivityAlert>[];

  /// Các thông báo đã tải về (chưa chắc là hết, xem [alertsHasMore]).
  List<ActivityAlert> get alerts => UnmodifiableListView(_alerts);

  /// Tổng số thông báo trên server — số hiện trên chuông.
  int get alertCount => _alertTotal;
  var _alertTotal = 0;

  /// Còn trang trên server chưa tải.
  bool get alertsHasMore => _alertsHasMore;
  var _alertsHasMore = true;

  var _alertPage = 0; // trang sẽ tải tiếp
  Future<void>? _alertsLoading;

  /// Tăng mỗi lần làm mới → kết quả của lần tải cũ (về muộn) bị bỏ qua.
  var _alertsVersion = 0;

  /// Tải trang thông báo tiếp theo. Đang tải dở → dùng lại lần đó,
  /// không gọi server 2 lần. Lỗi → ném [ApiException].
  Future<void> loadMoreAlerts() {
    if (!_alertsHasMore) return Future.value();
    if (_alertsLoading case final busy?) return busy;
    late final Future<void> load;
    load = _fetchAlerts(_alertPage).whenComplete(() {
      if (identical(_alertsLoading, load)) _alertsLoading = null;
    });
    return _alertsLoading = load;
  }

  /// Tải lại từ trang đầu. Danh sách cũ vẫn hiện cho tới khi có kết quả.
  Future<void> refreshAlerts() {
    _alertsVersion++;
    _alertsLoading = null;
    return _fetchAlerts(0);
  }

  Future<void> _fetchAlerts(int page) async {
    final version = _alertsVersion;
    final r = await api.fetchAlerts(page: page, size: alertPageSize);
    if (version != _alertsVersion) return;
    if (page == 0) _alerts.clear();
    _alerts.addAll(r.items);
    _alertPage = page + 1;
    _alertTotal = r.total;
    _alertsHasMore = r.hasMore;
    notifyListeners();
  }

  /// Ẩn [alert]. Trả về vị trí cũ để hoàn tác bằng [restoreAlert].
  // TODO: báo server khi có API.
  int? dismissAlert(ActivityAlert alert) {
    final i = _alerts.indexOf(alert);
    if (i < 0) return null;
    _alerts.removeAt(i);
    _alertTotal--;
    notifyListeners();
    return i;
  }

  void restoreAlert(int index, ActivityAlert alert) {
    _alerts.insert(index.clamp(0, _alerts.length), alert);
    _alertTotal++;
    notifyListeners();
  }

  // ───────────────────────── Làm mới ─────────────────────────

  /// Kéo xuống để làm mới. Hiện dữ liệu là mẫu nên chỉ giả chờ.
  // TODO: tải lại thiết bị, phòng, thông báo từ backend khi có API.
  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    notifyListeners();
  }

  /// Danh sách chưa có API (VD: thiết bị) cuộn tới cuối → giả chờ tải
  /// 1 trang; dữ liệu đã có sẵn trong máy.
  // TODO: chuyển sang gọi [api] như thông báo khi backend có API thiết bị.
  Future<void> loadPage() =>
      Future<void>.delayed(const Duration(milliseconds: 600));
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
