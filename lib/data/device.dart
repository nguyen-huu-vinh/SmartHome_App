import 'package:flutter/foundation.dart';

import 'home_device.dart';

/// Mẫu thiết bị: tìm thấy khi quét, hoặc chọn trong danh mục để thêm.
/// [group] là nhóm khi thêm vào nhà.
@immutable
class Device {
  const Device({required this.name, required this.image, required this.group});

  final String name;
  final String image;
  final DeviceGroup group;
}
