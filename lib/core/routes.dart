import 'package:flutter/material.dart';

import 'theme.dart';

/// Trang mới fade + trượt vào từ [from], trang cũ thu nhỏ và mờ đi.
Route<T> _route<T>(Widget page, Offset from, String? name) =>
    PageRouteBuilder<T>(
      settings: RouteSettings(name: name),
      transitionDuration: AppMotion.slow,
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, sec, child) {
        final ofs = CurvedAnimation(parent: anim, curve: AppMotion.curve);
        final out = CurvedAnimation(parent: sec, curve: AppMotion.curve);
        return ScaleTransition(
          scale: Tween(begin: 1.0, end: 0.94).animate(out),
          child: FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.6).animate(out),
            child: FadeTransition(
              opacity: ofs,
              child: SlideTransition(
                position: Tween(begin: from, end: Offset.zero).animate(ofs),
                child: child,
              ),
            ),
          ),
        );
      },
    );

/// Trượt nhẹ từ phải vào (đi tiếp trong cùng luồng).
/// [name] để quay lại đúng màn bằng `Navigator.popUntil`
/// (VD: `ScanDevicesScreen.route`).
Route<T> smoothRoute<T>(Widget page, {String? name}) =>
    _route(page, const Offset(0.15, 0), name);

/// Trượt từ dưới lên, trang cũ lùi ra sau (sang luồng mới: đăng nhập, ...).
Route<T> riseRoute<T>(Widget page, {String? name}) =>
    _route(page, const Offset(0, 0.25), name);
