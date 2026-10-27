import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthome_app/data/home_device.dart';
import 'package:smarthome_app/data/sample_data.dart';
import 'package:smarthome_app/screens/auth/login_phone_screen.dart';
import 'package:smarthome_app/screens/auth/login_screen.dart';
import 'package:smarthome_app/screens/auth/signup_screen.dart';
import 'package:smarthome_app/screens/auth/verify_screen.dart';
import 'package:smarthome_app/screens/home/device_list_screen.dart';
import 'package:smarthome_app/screens/home/home_screen.dart';
import 'package:smarthome_app/screens/home/room_details_screen.dart';
import 'package:smarthome_app/screens/onboarding_screen.dart';
import 'package:smarthome_app/screens/settings/legal_screen.dart';
import 'package:smarthome_app/screens/settings/profile_screen.dart';
import 'package:smarthome_app/screens/setup/add_devices_screen.dart';
import 'package:smarthome_app/screens/setup/add_models_screen.dart';
import 'package:smarthome_app/screens/setup/manage_homes_screen.dart';
import 'package:smarthome_app/screens/setup/manage_rooms_screen.dart';
import 'package:smarthome_app/screens/setup/scan_devices_screen.dart';
import 'package:smarthome_app/widgets/device_sheet/device_sheet.dart';

import 'helpers.dart';

// Mọi màn phải hiện được (không tràn, không lỗi) trên máy nhỏ / lớn và khi
// người dùng phóng to chữ hệ thống. Lỗi tràn bố cục làm test thất bại.

const _sizes = {
  'iPhone SE (320x568)': Size(320, 568),
  'iPhone 14 Pro Max (430x932)': Size(430, 932),
};

/// Màn hiện tĩnh (đợi được hết hiệu ứng).
final _screens = <String, Widget Function()>{
  'Onboarding': () => const OnboardingScreen(),
  'Login': () => const LoginScreen(),
  'Login phone': () => const LoginPhoneScreen(),
  'Sign up': () => const SignupScreen(),
  'Manage homes': () => const ManageHomesScreen(),
  'Add devices': () => const AddDevicesScreen(),
  'Add models': () => AddModelsScreen(category: SampleData.categories.first),
  'Manage rooms': () => const ManageRoomsScreen(devices: SampleData.nearby),
  'Home': () => const HomeScreen(),
  'Room details': () => RoomDetailsScreen(room: SampleData.rooms[1]),
  'View all': () => const DeviceListScreen(group: DeviceGroup.climate),
  'Profile': () => const ProfileScreen(),
  'Legal': () => const LegalScreen(doc: LegalDoc.terms),
};

/// Màn có hiệu ứng / hẹn giờ chạy mãi.
final _animated = <String, Widget Function()>{
  'Verify': () => const VerifyScreen(email: 'wrteam_design@gmail.com'),
  'Scan devices': () => const ScanDevicesScreen(),
};

void main() {
  for (final MapEntry(key: device, value: size) in _sizes.entries) {
    for (final textScale in [1.0, 1.3]) {
      final variant = '$device, chữ x$textScale';

      for (final MapEntry(key: name, value: screen) in _screens.entries) {
        testWidgets('$name — $variant', (t) async {
          await pumpApp(t, screen(), size: size, textScale: textScale);
        });
      }

      for (final MapEntry(key: name, value: screen) in _animated.entries) {
        testWidgets('$name — $variant', (t) async {
          await pumpApp(
            t,
            screen(),
            size: size,
            textScale: textScale,
            settle: false,
          );
          await unmount(t);
        });
      }

      testWidgets('Các tab Home — $variant', (t) async {
        await pumpApp(t, const HomeScreen(), size: size, textScale: textScale);
        for (final tab in ['Rooms', 'Notifications', 'Settings']) {
          await tapNav(t, tab);
        }
      });

      testWidgets('Bảng chi tiết từng loại thiết bị — $variant', (t) async {
        final app = await pumpApp(
          t,
          const Scaffold(),
          size: size,
          textScale: textScale,
        );
        final context = t.element(find.byType(Scaffold));
        for (final g in DeviceGroup.values) {
          showDeviceSheet(context, app.inGroup(g).first);
          await t.pumpAndSettle();
          Navigator.pop(context);
          await t.pumpAndSettle();
        }
      });
    }
  }
}
