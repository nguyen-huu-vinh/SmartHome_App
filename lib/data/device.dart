import 'package:flutter/foundation.dart';

/// Mẫu thiết bị: tìm thấy khi quét, hoặc chọn trong danh mục để thêm.
@immutable
class Device {
  const Device({required this.name, required this.image});

  final String name;
  final String image;
}
