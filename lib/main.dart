import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme.dart';
import 'data/app_state.dart';
import 'screens/splash_screen.dart';

void main() {
  // Font đã đóng gói trong assets/fonts → không tải qua mạng.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(_fontLicenses);
  runApp(AppScope(state: AppState(), child: const HoomeApp()));
}

/// Giấy phép SIL OFL của 2 font đóng gói (hiện ở trang giấy phép của app).
Stream<LicenseEntry> _fontLicenses() async* {
  for (final font in ['Inter', 'Nunito']) {
    final text = await rootBundle.loadString('assets/fonts/OFL_$font.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts ($font)'], text);
  }
}

class HoomeApp extends StatelessWidget {
  const HoomeApp({super.key, this.home = const SplashScreen()});

  /// Màn đầu tiên (test có thể mở thẳng 1 màn bất kỳ).
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hoome',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) => GestureDetector(
        // Chạm ra ngoài ô nhập → ẩn bàn phím.
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        // Bố cục theo thiết kế có nhiều chỗ cao cố định → giới hạn cỡ chữ
        // hệ thống để không bị tràn, vẫn cho phóng to vừa phải.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: child!,
        ),
      ),
      home: home,
    );
  }
}
