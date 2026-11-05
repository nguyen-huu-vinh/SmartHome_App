import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/feedback.dart';
import 'core/theme.dart';
import 'data/app_state.dart';
import 'data/fake_home_api.dart';
import 'l10n/l10n.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleSignIn.instance.initialize();
  // Font đã đóng gói trong assets/fonts → không tải qua mạng.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(_fontLicenses);
  final app = AppState(api: FakeHomeApi(persist: true));
  await app.loadLocale();
  runApp(AppScope(state: app, child: const HoomeApp()));
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
    // Đổi ngôn ngữ ở Settings → cả app vẽ lại bằng ngôn ngữ mới.
    return ValueListenableBuilder(
      valueListenable: AppScope.read(context).locale,
      builder: (_, locale, _) => _app(locale),
    );
  }

  Widget _app(Locale? locale) {
    return MaterialApp(
      title: 'Hoome',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // null → theo ngôn ngữ của máy (máy không phải tiếng Việt → tiếng Anh).
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => GestureDetector(
        // Chạm ra ngoài ô nhập → ẩn bàn phím.
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        // Bố cục theo thiết kế có nhiều chỗ cao cố định → giới hạn cỡ chữ
        // hệ thống để không bị tràn, vẫn cho phóng to vừa phải.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: _ErrorToasts(child: child!),
        ),
      ),
      home: home,
    );
  }
}

/// Lỗi từ [AppState.errors] (VD: mất mạng khi bật đèn) → thông báo nổi,
/// ở bất kỳ màn nào.
class _ErrorToasts extends StatefulWidget {
  const _ErrorToasts({required this.child});

  final Widget child;

  @override
  State<_ErrorToasts> createState() => _ErrorToastsState();
}

class _ErrorToastsState extends State<_ErrorToasts> {
  StreamSubscription<AppError>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sub?.cancel();
    _sub = AppScope.read(context).errors.listen(_show);
  }

  void _show(AppError e) {
    final l = context.l10n;
    context.toast(switch (e) {
      SwitchError(device: final name?, on: true) => l.couldntTurnOn(name),
      SwitchError(device: final name?, on: false) => l.couldntTurnOff(name),
      SwitchError() => l.couldntUpdateDevices,
      SaveError(kind: SaveKind.addRoom) => l.couldntAddRoom,
      SaveError(kind: SaveKind.removeRoom) => l.couldntRemoveRoom,
      SaveError(kind: SaveKind.saveHomes) => l.couldntSaveHomes,
      SaveError(kind: SaveKind.refresh) => l.couldntRefresh,
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
