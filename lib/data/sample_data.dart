import 'package:flutter/material.dart';

import 'activity_alert.dart';
import 'country.dart';
import 'device.dart';
import 'device_category.dart';
import 'home_device.dart';
import 'room.dart';
import 'user.dart';

/// Toàn bộ dữ liệu giả của app, dùng cho tới khi có API / quét thiết bị thật.
/// Khi nối API: cho `AppState` lấy dữ liệu từ server thay vì từ đây.
///
/// Ảnh thiết bị tạm cắt từ thiết kế, icon phòng tạm dùng icon Material —
/// thay bằng ảnh / SVG gốc khi có.
abstract final class SampleData {
  static const _home = 'assets/images/home';
  static const _devices = 'assets/images/devices';
  static const _models = 'assets/images/models';
  static const _categories = 'assets/images/categories';

  static const profile = Profile(
    name: 'Varun R',
    country: Country.india,
    phone: '2625832131213',
    email: 'info@example.com',
  );

  static const rooms = [
    Room(
      name: 'Main Hall',
      icon: Icons.chair_rounded,
      color: Color(0xFF4DB8FF),
    ),
    Room(
      name: 'Kitchen',
      icon: Icons.soup_kitchen_rounded,
      color: Color(0xFFFFA05C),
    ),
    Room(name: 'Bedroom', icon: Icons.bed_rounded, color: Color(0xFFF27C7C)),
    Room(
      name: 'Bathroom',
      icon: Icons.checkroom_rounded,
      color: Color(0xFF5B7CFF),
    ),
    Room(
      name: 'Dining Area',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFF6FD3A0),
    ),
    Room(
      name: 'Play Area',
      icon: Icons.sports_basketball_rounded,
      color: Color(0xFFFF7A45),
    ),
  ];

  /// Thiết bị đã có trong nhà.
  static const devices = [
    HomeDevice(
      name: 'Plueto Smart L30',
      image: '$_home/desk_lamp.png',
      group: DeviceGroup.lights,
      room: 'Main Hall',
    ),
    HomeDevice(
      name: 'Zora Aync - Warm Light',
      image: '$_home/pendant_grey.png',
      group: DeviceGroup.lights,
      room: 'Kitchen',
    ),
    HomeDevice(
      name: 'Zora Sonic - Warm Light',
      image: '$_home/pendant_black.png',
      group: DeviceGroup.lights,
      room: 'Kitchen',
      on: true,
    ),
    // Cùng 1 mẫu đèn bàn đặt ở 3 phòng.
    HomeDevice(
      name: 'Lumana Supra H45',
      image: '$_home/table_lamp.png',
      group: DeviceGroup.lights,
      room: 'Main Hall',
      on: true,
    ),
    HomeDevice(
      name: 'Lumana Supra H45',
      image: '$_home/table_lamp.png',
      group: DeviceGroup.lights,
      room: 'Kitchen',
      volts: 232,
    ),
    HomeDevice(
      name: 'Lumana Supra H45',
      image: '$_home/table_lamp.png',
      group: DeviceGroup.lights,
      room: 'Bedroom',
    ),
    // Cùng 1 mẫu camera đặt ở 3 phòng.
    HomeDevice(
      name: 'Tapo TP-Link C210 360°',
      image: '$_models/tapo_c210.png',
      group: DeviceGroup.security,
      room: 'Bedroom',
      on: true,
      preview: '$_home/feed_bedroom.png',
    ),
    HomeDevice(
      name: 'Tapo TP-Link C210 360°',
      image: '$_models/tapo_c210.png',
      group: DeviceGroup.security,
      room: 'Main Hall',
      on: true,
      preview: '$_home/feed_hall.png',
    ),
    HomeDevice(
      name: 'Tapo TP-Link C210 360°',
      image: '$_models/tapo_c210.png',
      group: DeviceGroup.security,
      room: 'Kitchen',
      on: true,
    ),
    HomeDevice(
      name: 'Tapo C201 360°',
      image: '$_models/tapo_c201.png',
      group: DeviceGroup.security,
      room: 'Bedroom',
    ),
    HomeDevice(
      name: 'Xiaemi Su 7 Smart TV',
      image: '$_home/tv.png',
      group: DeviceGroup.entertainment,
      room: 'Bedroom',
    ),
    HomeDevice(
      name: 'Amazon Alexa 2',
      image: '$_devices/speaker.png',
      group: DeviceGroup.entertainment,
      room: 'Kitchen',
    ),
    // Cùng 1 mẫu máy lạnh đặt ở 3 phòng.
    HomeDevice(
      name: 'Samsungva AC',
      image: '$_home/ac.png',
      group: DeviceGroup.climate,
      room: 'Main Hall',
      on: true,
    ),
    HomeDevice(
      name: 'Samsungva AC',
      image: '$_home/ac.png',
      group: DeviceGroup.climate,
      room: 'Kitchen',
    ),
    HomeDevice(
      name: 'Samsungva AC',
      image: '$_home/ac.png',
      group: DeviceGroup.climate,
      room: 'Bedroom',
    ),
    HomeDevice(
      name: 'Native RO 32U',
      image: '$_home/purifier.png',
      group: DeviceGroup.appliances,
      room: 'Kitchen',
      on: true,
    ),
    HomeDevice(
      name: 'Luna Smart Fridge',
      image: '$_home/fridge.png',
      group: DeviceGroup.appliances,
      room: 'Kitchen',
      on: true,
    ),
    HomeDevice(
      name: 'Eroka Smart Cleaner',
      image: '$_home/cleaner_thumb.png',
      group: DeviceGroup.cleaning,
      room: 'Kitchen',
      on: true,
    ),
  ];

  /// Thông báo ở tab Activity Alerts.
  static const alerts = [
    ActivityAlert(
      kind: AlertKind.suggestion,
      title: '11:30 PM',
      message: 'Would you like to turn off the hall’s lights?',
      image: '$_home/alert_pendant.png',
      age: Duration(minutes: 2),
      room: 'Main Hall',
    ),
    ActivityAlert(
      kind: AlertKind.disconnected,
      title: 'Imue S7 Cam 4 Disconnected',
      message: 'Currently not monitoring, kindly re-connect',
      image: '$_home/alert_cam.png',
      age: Duration(minutes: 12),
    ),
    ActivityAlert(
      kind: AlertKind.turnedOff,
      title: 'Syscka Olo Turned off',
      message: 'Your Syscka Olo Table Lamp turned off',
      image: '$_home/alert_lamp.png',
      age: Duration(hours: 2),
    ),
  ];

  /// Thiết bị "tìm thấy" khi quét Bluetooth / Wi-Fi.
  static const nearby = [
    Device(name: 'Havells Glamax 9W B22', image: '$_devices/bulb.png'),
    Device(name: 'Tapo TP-Link C210 360°', image: '$_devices/camera.png'),
    Device(name: 'Amazon Alexa 2', image: '$_devices/speaker.png'),
    Device(name: 'Philips Pendant Lamp', image: '$_devices/lamp.png'),
  ];

  /// Loại thiết bị ở màn "Add Devices".
  static const categories = [
    DeviceCategory(
      name: 'Camera',
      image: '$_categories/camera.png',
      count: '22',
      models: [
        Device(name: 'Tapo C201 360°', image: '$_models/tapo_c201.png'),
        Device(name: 'Tapo C301 180°', image: '$_models/tapo_c301.png'),
        Device(
          name: 'Imou 360° 1080P Full HD Security Camera',
          image: '$_models/imou_360.png',
        ),
        Device(name: 'Tapo TP-Link C210', image: '$_models/tapo_c210.png'),
      ],
    ),
    DeviceCategory(
      name: 'Digital Assistant',
      image: '$_categories/assistant.png',
      count: '125+',
    ),
    DeviceCategory(
      name: 'Air Conditioner',
      image: '$_categories/ac.png',
      count: '232+',
    ),
    DeviceCategory(
      name: 'Fridge',
      image: '$_categories/fridge.png',
      count: '232+',
    ),
    DeviceCategory(
      name: 'Water Purifier',
      image: '$_categories/purifier.png',
      count: '345+',
    ),
  ];
}
