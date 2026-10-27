// Tạm thời: chụp ảnh các màn để so sánh trước/sau khi tối ưu.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthome_app/core/theme.dart';
import 'package:smarthome_app/data/app_state.dart';
import 'package:smarthome_app/data/country.dart';
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
import 'package:smarthome_app/screens/setup/adding_device_screen.dart';
import 'package:smarthome_app/screens/setup/manage_homes_screen.dart';
import 'package:smarthome_app/screens/setup/manage_rooms_screen.dart';
import 'package:smarthome_app/screens/setup/scan_devices_screen.dart';
import 'package:smarthome_app/screens/splash_screen.dart';
import 'package:smarthome_app/widgets/country_picker.dart';
import 'package:smarthome_app/widgets/device_sheet/device_sheet.dart';
import 'package:smarthome_app/widgets/manage_homes_sheet.dart';
import 'package:smarthome_app/widgets/manage_room_sheet.dart';
import 'package:smarthome_app/widgets/name_input_sheet.dart';

const _dir = 'goldens/after';

Future<void> _font(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

Future<void> _loadFonts() async {
  const f =
      '/Users/badboy/Downloads/flutter/bin/cache/artifacts/material_fonts';
  // Font thật của app (đóng gói trong assets/fonts).
  await _font('Inter_regular', 'assets/fonts/Inter-Regular.ttf');
  await _font('Inter_500', 'assets/fonts/Inter-Medium.ttf');
  await _font('Inter_600', 'assets/fonts/Inter-SemiBold.ttf');
  await _font('Inter_700', 'assets/fonts/Inter-Bold.ttf');
  await _font('Nunito_900', 'assets/fonts/Nunito-Black.ttf');
  await _font('Roboto', '$f/Roboto-Regular.ttf');
  await _font('MaterialIcons', '$f/MaterialIcons-Regular.otf');
}

Widget _app(Widget home) => AppScope(
  state: AppState(),
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: home,
  ),
);

/// Màn có nút "open" → chạy [open] để mở bảng.
Widget _launcher(void Function(BuildContext) open) => _app(
  Scaffold(
    body: Builder(
      builder: (c) => Center(
        child: TextButton(onPressed: () => open(c), child: const Text('open')),
      ),
    ),
  ),
);

Future<void> _precache(WidgetTester t) async {
  await t.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
}

Future<void> _settle(WidgetTester t, bool settle) async {
  if (settle) {
    await t.pumpAndSettle();
  } else {
    for (var i = 0; i < 10; i++) {
      await t.pump(const Duration(milliseconds: 60));
    }
  }
}

void shot(
  String name,
  Widget Function() app, {
  Future<void> Function(WidgetTester t)? act,
  bool settle = true,
  Size size = const Size(375, 812),
}) {
  testWidgets(name, (t) async {
    t.view.physicalSize = size * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(app());
    await _settle(t, settle);
    if (act != null) await act(t);
    await _settle(t, settle);
    await _precache(t);
    await _settle(t, settle);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('$_dir/$name.png'),
    );
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 3));
  });
}

Future<void> _open(WidgetTester t) async {
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
}

const _d = SampleData.devices;

void main() {
  setUpAll(_loadFonts);

  shot('01_splash', () => _app(const SplashScreen()), settle: false);
  shot('02_onboarding', () => _app(const OnboardingScreen()));
  shot('03_login', () => _app(const LoginScreen()));
  shot('04_login_phone', () => _app(const LoginPhoneScreen()));
  shot('05_signup', () => _app(const SignupScreen()));
  shot(
    '06_verify',
    () => _app(const VerifyScreen(email: 'wrteam_design@gmail.com')),
    settle: false,
  );
  shot('07_manage_homes', () => _app(const ManageHomesScreen()));
  shot('08_scan', () => _app(const ScanDevicesScreen()), settle: false);
  shot('09_add_devices', () => _app(const AddDevicesScreen()));
  shot(
    '10_add_models',
    () => _app(AddModelsScreen(category: SampleData.categories.first)),
  );
  shot(
    '11_adding',
    () => _app(const AddingDeviceScreen(devices: SampleData.nearby)),
    settle: false,
  );
  shot(
    '12_manage_rooms',
    () => _app(const ManageRoomsScreen(devices: SampleData.nearby)),
  );
  shot('13_home', () => _app(const HomeScreen()));
  shot(
    '14_rooms',
    () => _app(const HomeScreen()),
    act: (t) async {
      await t.tap(find.byTooltip('Rooms'));
    },
  );
  shot(
    '15_alerts',
    () => _app(const HomeScreen()),
    act: (t) async {
      await t.tap(find.byTooltip('Notifications'));
    },
  );
  shot(
    '16_settings',
    () => _app(const HomeScreen()),
    act: (t) async {
      await t.tap(find.byTooltip('Settings'));
    },
  );
  shot('17_profile', () => _app(const ProfileScreen()));
  shot('18_legal', () => _app(const LegalScreen(doc: LegalDoc.terms)));
  shot(
    '19_device_list',
    () => _app(const DeviceListScreen(group: DeviceGroup.lights)),
  );
  shot(
    '20_room_details',
    () => _app(RoomDetailsScreen(room: SampleData.rooms[1])),
  );
  for (final (name, d) in [
    ('21_sheet_light', _d[3]),
    ('22_sheet_ac', _d[12]),
    ('23_sheet_camera', _d[7]),
    ('24_sheet_cleaner', _d.last),
    ('29_sheet_fridge', _d[16]),
  ]) {
    shot(name, () => _launcher((c) => showDeviceSheet(c, d)), act: _open);
  }
  shot(
    '25_sheet_manage_room',
    () => _launcher(
      (c) => showManageRoomSheet(
        c,
        initial: SampleData.rooms[1],
        onAddDevice: (_) {},
      ),
    ),
    act: _open,
  );
  shot(
    '26_sheet_homes',
    () => _launcher(
      (c) => showManageHomesSheet(c, homes: ['My Home', 'Office'], index: 0),
    ),
    act: _open,
  );
  shot('27_sheet_name', () => _launcher(showAddRoomSheet), act: _open);
  shot(
    '28_sheet_country',
    () => _launcher((c) => showCountryPicker(c, Country.india)),
    act: _open,
  );
}
