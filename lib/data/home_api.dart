import 'activity_alert.dart';
import 'home_device.dart';
import 'room.dart';

/// 1 trang kết quả từ server.
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.total,
    required this.hasMore,
  });

  final List<T> items;

  /// Tổng số mục trên server (VD: số trên chuông thông báo).
  final int total;

  /// Còn trang sau không.
  final bool hasMore;
}

/// Gọi server thất bại (mất mạng, server lỗi...).
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Các hàm app cần từ backend. Hiện dùng `FakeHomeApi`; khi có backend thì
/// viết lớp gọi HTTP `implements HomeApi` rồi truyền vào `AppState`.
/// Mọi hàm lỗi (mất mạng, server lỗi) đều ném [ApiException].
abstract interface class HomeApi {
  /// Thông báo, mới nhất trước. [page] tính từ 0.
  Future<PageResult<ActivityAlert>> fetchAlerts({
    required int page,
    required int size,
  });

  // ───────────── Nhà ─────────────

  /// Tên các nhà đã tạo; rỗng = chưa tạo nhà nào.
  Future<List<String>> fetchHomes();

  /// Lưu lại cả danh sách nhà (thêm, xoá, đổi tên đều đi qua đây).
  Future<void> saveHomes(List<String> homes);

  // ───────────── Phòng ─────────────

  Future<List<Room>> fetchRooms();

  /// Thêm [room] vào cuối danh sách, hoặc vào vị trí [index] (hoàn tác xoá).
  /// Đã có phòng cùng tên → giữ nguyên.
  Future<void> addRoom(Room room, {int? index});

  Future<void> removeRoom(Room room);

  // ───────────── Thiết bị ─────────────

  /// Thiết bị trong nhà, kèm trạng thái bật/tắt hiện tại ([HomeDevice.on]).
  Future<List<HomeDevice>> fetchDevices();

  /// Thêm thiết bị (mỗi máy đã có [HomeDevice.room]). Trả về các máy đã lưu:
  /// server đặt mã [HomeDevice.id], thêm 2 máy cùng mẫu vào 1 phòng vẫn
  /// có 2 mã khác nhau.
  Future<List<HomeDevice>> addDevices(List<HomeDevice> devices);

  /// Bật/tắt [device].
  Future<void> setDeviceOn(HomeDevice device, bool on);
}
