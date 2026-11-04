import 'activity_alert.dart';

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
abstract interface class HomeApi {
  /// Thông báo, mới nhất trước. [page] tính từ 0.
  Future<PageResult<ActivityAlert>> fetchAlerts({
    required int page,
    required int size,
  });
}
