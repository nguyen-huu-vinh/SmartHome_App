import 'dart:math';

import 'activity_alert.dart';
import 'home_api.dart';
import 'sample_data.dart';

/// "Server giả" khi chưa có backend: dữ liệu lấy từ [SampleData] nhưng trả
/// về y như API thật — chờ mạng, chia trang, thỉnh thoảng lỗi.
class FakeHomeApi implements HomeApi {
  FakeHomeApi({
    List<ActivityAlert>? alerts,
    this.delay,
    this.failRate = 0.1,
    Random? random,
  }) : _alerts = alerts ?? manyAlerts(35),
       _random = random ?? Random();

  /// Dùng trong test: 3 thông báo mẫu, trả ngay, không bao giờ lỗi.
  FakeHomeApi.instant()
    : this(alerts: SampleData.alerts, delay: Duration.zero, failRate: 0);

  final List<ActivityAlert> _alerts;
  final Random _random;

  /// Thời gian chờ mỗi lần gọi; null → ngẫu nhiên 0,5–1,5 giây.
  final Duration? delay;

  /// Tỉ lệ gọi bị lỗi: 0 → không bao giờ, 1 → luôn lỗi.
  double failRate;

  @override
  Future<PageResult<ActivityAlert>> fetchAlerts({
    required int page,
    required int size,
  }) async {
    final wait = delay ?? Duration(milliseconds: 500 + _random.nextInt(1000));
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    if (_random.nextDouble() < failRate) {
      throw const ApiException('No internet connection');
    }
    // Giống LIMIT/OFFSET ở backend.
    final start = page * size;
    return PageResult(
      items: _alerts.skip(start).take(size).toList(),
      total: _alerts.length,
      hasMore: start + size < _alerts.length,
    );
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
