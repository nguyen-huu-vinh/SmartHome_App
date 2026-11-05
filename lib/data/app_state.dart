import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'activity_alert.dart';
import 'device_settings.dart';
import 'fake_home_api.dart';
import 'home_api.dart';
import 'home_device.dart';
import 'room.dart';
import 'sample_data.dart';
import 'user.dart';

/// Lỗi cần báo cho người dùng (xem [AppState.errors]).
sealed class AppError {
  const AppError();
}

/// Bật/tắt thất bại: [device] là tên máy (null → nhiều máy), [on] là
/// trạng thái người dùng muốn.
final class SwitchError extends AppError {
  const SwitchError({this.device, required this.on});

  final String? device;
  final bool on;

  @override
  bool operator ==(Object other) =>
      other is SwitchError && other.device == device && other.on == on;

  @override
  int get hashCode => Object.hash(device, on);
}

/// Việc app đã làm ngay trên màn hình nhưng server không nhận.
enum SaveKind { addRoom, removeRoom, saveHomes, refresh }

final class SaveError extends AppError {
  const SaveError(this.kind);

  final SaveKind kind;

  @override
  bool operator ==(Object other) => other is SaveError && other.kind == kind;

  @override
  int get hashCode => kind.hashCode;
}

/// Toàn bộ dữ liệu dùng chung khi app đang chạy: hồ sơ, tuỳ chọn, nhà,
/// phòng, thiết bị (bật/tắt + cài đặt riêng), thông báo.
///
/// - Màn hình đọc qua `AppScope.of(context)` → tự vẽ lại khi dữ liệu đổi,
///   không cần truyền dữ liệu qua từng màn.
/// - Mọi thay đổi đi qua các hàm ở đây (danh sách trả ra chỉ để đọc).
/// - Dữ liệu đi qua [api] (hiện là [FakeHomeApi]): mở app thì tải nhà, phòng,
///   thiết bị, thông báo; mỗi thay đổi (thêm phòng, bật đèn...) hiện ngay trên
///   màn hình rồi báo server, server lỗi thì trả về như cũ.
/// - [SampleData] chỉ là dữ liệu hiện tạm trước khi tải xong.
class AppState extends ChangeNotifier {
  AppState({
    List<HomeDevice> devices = SampleData.devices,
    List<Room> rooms = SampleData.rooms,
    HomeApi? api,
  }) : api = api ?? FakeHomeApi(),
       _devices = [...devices],
       _rooms = [...rooms],
       _on = {for (final d in devices) d: d.on} {
    // Tải sẵn trang đầu để chuông có số ngay. Lỗi thì tab thông báo tự thử lại.
    loadMoreAlerts().ignore();
    // Lỗi thì giữ dữ liệu tạm, kéo để làm mới sẽ thử lại.
    for (final load in [loadHomes, loadRooms, loadDevices]) {
      _loadWithRetry(load).ignore();
    }
  }

  /// Nơi lấy dữ liệu (server thật hoặc giả).
  final HomeApi api;

  /// Lỗi cần báo cho người dùng (VD: mất mạng khi bật đèn). App lắng nghe
  /// và hiện thông báo nổi theo ngôn ngữ đang chọn.
  Stream<AppError> get errors => _errors.stream;
  final _errors = StreamController<AppError>.broadcast();

  @override
  void dispose() {
    _errors.close();
    locale.dispose();
    super.dispose();
  }

  // ───────────────────────── Ngôn ngữ ─────────────────────────

  static const _localeKey = 'locale';

  /// Ngôn ngữ người dùng chọn; null → theo ngôn ngữ của máy.
  final locale = ValueNotifier<Locale?>(null);

  /// Đọc ngôn ngữ đã chọn lần trước (gọi 1 lần khi mở app).
  Future<void> loadLocale() async {
    final code = (await SharedPreferences.getInstance()).getString(_localeKey);
    if (code != null) locale.value = Locale(code);
  }

  Future<void> setLocale(Locale value) async {
    locale.value = value;
    await (await SharedPreferences.getInstance()).setString(
      _localeKey,
      value.languageCode,
    );
  }

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
  List<String> get homes => homesOr('My Home');

  /// Như [homes], nhà mặc định mang tên [fallback] (VD: theo ngôn ngữ).
  List<String> homesOr(String fallback) => hasHomes ? _homes : [fallback];

  /// Nhà đang chọn (vị trí trong [homes]).
  int get homeIndex => _homeIndex.clamp(0, homes.length - 1);

  /// Tăng mỗi lần đổi nhà → kết quả tải / lưu cũ (về muộn) bị bỏ qua.
  var _homesVersion = 0;

  /// Các lần lưu nhà xếp hàng, đi lên server đúng thứ tự.
  Future<void> _homesQueue = Future.value();

  /// Lấy danh sách nhà từ server. Lỗi → ném [ApiException].
  Future<void> loadHomes() async {
    final version = _homesVersion;
    final saved = await api.fetchHomes();
    if (version != _homesVersion) return; // vừa sửa nhà → bỏ kết quả cũ
    _homes = List.unmodifiable(saved);
    notifyListeners();
  }

  /// Đặt lại cả danh sách nhà (thêm, xoá, đổi tên). Hiện ngay, rồi báo
  /// server; server lỗi → trả về danh sách cũ và [errors] báo người dùng.
  void setHomes(List<String> homes, {int index = 0}) {
    final before = (_homes, _homeIndex);
    _homes = List.unmodifiable(homes);
    _homeIndex = index;
    final version = ++_homesVersion;
    notifyListeners();
    _saveHomes(_homes, version, before).ignore();
  }

  Future<void> _saveHomes(
    List<String> homes,
    int version,
    (List<String>, int) before,
  ) async {
    final turn = _homesQueue;
    final done = Completer<void>();
    _homesQueue = done.future;
    await turn;
    try {
      await api.saveHomes(homes);
    } on ApiException {
      if (version == _homesVersion) {
        _homes = before.$1;
        _homeIndex = before.$2;
        notifyListeners();
      }
      _errors.add(const SaveError(SaveKind.saveHomes));
    } finally {
      done.complete();
    }
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

  /// Có phòng tên [name] chưa (không phân biệt hoa thường)?
  bool hasRoom(String name) {
    final n = name.trim().toLowerCase();
    return _rooms.any((r) => r.name.toLowerCase() == n);
  }

  var _roomsVersion = 0;
  var _roomsPending = 0;

  /// Lấy danh sách phòng từ server. Lỗi → ném [ApiException].
  Future<void> loadRooms() async {
    final version = _roomsVersion;
    final saved = await api.fetchRooms();
    // Đang sửa phòng dở → kết quả này có thể đã cũ. Giao diện luôn cần
    // ít nhất 1 phòng → server chưa có phòng nào thì giữ phòng hiện có.
    if (version != _roomsVersion || _roomsPending > 0 || saved.isEmpty) return;
    _rooms
      ..clear()
      ..addAll(saved);
    notifyListeners();
  }

  /// Hiện ngay rồi báo server; server lỗi → [undo] và báo người dùng.
  Future<void> _roomOp(
    Future<void> Function() send, {
    required VoidCallback undo,
    required SaveKind failed,
  }) async {
    _roomsVersion++;
    _roomsPending++;
    notifyListeners();
    try {
      await send();
    } on ApiException {
      undo();
      notifyListeners();
      _errors.add(SaveError(failed));
    } finally {
      _roomsPending--;
    }
  }

  /// Thêm [room] vào cuối. Đã có phòng cùng tên thì không thêm (xem [hasRoom]).
  Future<void> addRoom(Room room) {
    if (hasRoom(room.name)) return Future.value();
    _rooms.add(room);
    return _roomOp(
      () => api.addRoom(room),
      undo: () => _rooms.remove(room),
      failed: SaveKind.addRoom,
    );
  }

  /// Xoá [room]. Trả về vị trí cũ để hoàn tác bằng [insertRoom];
  /// null = không xoá (không có phòng này, hoặc là phòng cuối cùng).
  int? removeRoom(Room room) {
    final i = _rooms.indexOf(room);
    if (i < 0 || !canRemoveRoom) return null;
    _rooms.removeAt(i);
    _roomOp(
      () => api.removeRoom(room),
      undo: () => _rooms.insert(i.clamp(0, _rooms.length), room),
      failed: SaveKind.removeRoom,
    ).ignore();
    return i;
  }

  void insertRoom(int index, Room room) {
    if (hasRoom(room.name)) return;
    _rooms.insert(index.clamp(0, _rooms.length), room);
    _roomOp(
      () => api.addRoom(room, index: index),
      undo: () => _rooms.remove(room),
      failed: SaveKind.addRoom,
    ).ignore();
  }

  // ───────────────────────── Thiết bị ─────────────────────────

  final List<HomeDevice> _devices;
  List<HomeDevice> get devices => UnmodifiableListView(_devices);
  final Map<HomeDevice, bool> _on;

  /// Tăng mỗi lần thêm thiết bị → kết quả tải cũ (về muộn) bị bỏ qua.
  var _devicesVersion = 0;

  bool isOn(HomeDevice d) => _on[d] ?? false;

  /// Trạng thái server đã xác nhận (chưa có → như ban đầu).
  final _serverOn = <HomeDevice, bool>{};

  /// Đếm số lần bấm mỗi máy → chỉ báo lỗi cho lần bấm mới nhất.
  final _onTaps = <HomeDevice, int>{};

  /// Số yêu cầu bật/tắt đang chờ server của mỗi máy.
  final _pending = <HomeDevice, int>{};

  Future<void> setOn(HomeDevice d, bool on) => setAllOn([d], on);

  Future<void> toggle(HomeDevice d) => setOn(d, !isOn(d));

  /// Bật/tắt nhiều thiết bị cùng lúc (VD: cả dãy đèn 1 phòng).
  ///
  /// Công tắc đổi ngay trên màn hình rồi mới báo server. Server lỗi → máy
  /// đó trở về như cũ và [errors] báo cho người dùng.
  Future<void> setAllOn(Iterable<HomeDevice> list, bool on) async {
    final changed = [
      for (final d in list)
        if (isOn(d) != on) d,
    ];
    if (changed.isEmpty) return;
    for (final d in changed) {
      _on[d] = on;
    }
    notifyListeners();
    final ok = await Future.wait([for (final d in changed) _sendOn(d, on)]);
    if (ok.every((v) => v)) return;
    _errors.add(
      SwitchError(
        device: changed.length == 1 ? changed.single.name : null,
        on: on,
      ),
    );
  }

  /// Lấy danh sách thiết bị (kèm trạng thái bật/tắt) từ server. Máy vừa được
  /// bấm trong lúc chờ thì giữ theo lần bấm đó. Lỗi → ném [ApiException].
  Future<void> loadDevices() async {
    final version = _devicesVersion;
    final taps = {..._onTaps};
    final busy = {
      for (final d in _devices)
        if (_isPending(d)) d,
    };
    final saved = await api.fetchDevices();
    if (version != _devicesVersion) return; // vừa thêm máy → kết quả đã cũ
    final next = <HomeDevice, bool>{};
    for (final d in saved) {
      // Máy được bấm trong lúc chờ → kết quả này có thể đã cũ, bỏ qua.
      final keep = busy.contains(d) || _isPending(d) || _onTaps[d] != taps[d];
      next[d] = keep ? _on[d] ?? d.on : d.on;
      if (!keep) _serverOn[d] = d.on;
    }
    _devices
      ..clear()
      ..addAll(saved);
    _on
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  /// Thêm thiết bị vào nhà (mỗi máy đã có [HomeDevice.room]); xong mới hiện.
  /// Server lỗi → ném [ApiException], không thêm gì.
  Future<void> addDevices(List<HomeDevice> devices) async {
    final saved = await api.addDevices(devices);
    _devicesVersion++;
    for (final d in saved) {
      _devices.add(d);
      _on[d] = d.on;
      _serverOn[d] = d.on;
    }
    notifyListeners();
  }

  /// Gọi [load]; lỗi → thử lại sau 1 rồi 2 giây, vẫn lỗi thì thôi.
  Future<void> _loadWithRetry(Future<void> Function() load) async {
    for (var attempt = 0; ; attempt++) {
      try {
        return await load();
      } on ApiException {
        if (attempt == 2) return;
        await Future<void>.delayed(Duration(seconds: 1 << attempt));
      }
    }
  }

  bool _isPending(HomeDevice d) => (_pending[d] ?? 0) > 0;

  /// Báo server. Trả về false nếu lần bấm mới nhất của máy bị lỗi.
  ///
  /// Yêu cầu cuối cùng của máy xong → công tắc theo đúng trạng thái server
  /// đã xác nhận (VD: lần bấm trước thành công về muộn sau lần bấm sau lỗi).
  Future<bool> _sendOn(HomeDevice d, bool on) async {
    final tap = _onTaps[d] = (_onTaps[d] ?? 0) + 1;
    _pending[d] = (_pending[d] ?? 0) + 1;
    var ok = true;
    try {
      await api.setDeviceOn(d, on);
      _serverOn[d] = on;
    } on ApiException {
      ok = false;
    }
    _pending[d] = _pending[d]! - 1;
    if (!_isPending(d)) {
      final server = _serverOn[d] ?? d.on;
      if (_on[d] != server) {
        _on[d] = server;
        notifyListeners();
      }
    }
    return ok || _onTaps[d] != tap;
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

  /// Kéo xuống để làm mới: tải lại nhà, phòng, thiết bị. Lỗi → [errors] báo.
  Future<void> refresh() async {
    try {
      await Future.wait([loadHomes(), loadRooms(), loadDevices()]);
    } on ApiException {
      _errors.add(const SaveError(SaveKind.refresh));
    }
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
