import 'package:flutter/foundation.dart';

import 'device.dart';

/// Loại thiết bị có thể thêm thủ công, kèm các mẫu cụ thể ([models]).
@immutable
class DeviceCategory {
  const DeviceCategory({
    required this.name,
    required this.image,
    required this.count,
    this.models = const [],
  });

  final String name;
  final String image;

  /// Số mẫu hỗ trợ, VD: "22", "125+".
  final String count;

  /// Các mẫu có thể chọn để thêm. Rỗng = chưa có dữ liệu.
  final List<Device> models;
}
