import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chạy trước mọi file test: nạp font thật của app (assets/fonts) để chữ đo
/// đúng kích thước như trên máy thật → kiểm tra tràn bố cục mới đáng tin.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  const fonts = {
    'Inter_regular': 'Inter-Regular',
    'Inter_500': 'Inter-Medium',
    'Inter_600': 'Inter-SemiBold',
    'Inter_700': 'Inter-Bold',
    'Nunito_900': 'Nunito-Black',
  };
  for (final MapEntry(key: family, value: file) in fonts.entries) {
    final bytes = File('assets/fonts/$file.ttf').readAsBytesSync();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
  await testMain();
}
