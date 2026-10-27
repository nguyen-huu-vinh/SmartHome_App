import 'package:flutter/material.dart';

import 'theme.dart';

/// "1 Device", "3 Devices".
String plural(int count, String noun) =>
    '$count ${count == 1 ? noun : '${noun}s'}';

/// Phản hồi ngắn cho người dùng: thông báo nổi, hộp thoại xác nhận.
extension AppFeedback on BuildContext {
  /// Thông báo nổi ở đáy màn hình (thay thông báo đang hiện, nếu có).
  /// Có [action] (VD: "Undo") → hiện nút, bấm thì chạy [onAction].
  void toast(String message, {String? action, VoidCallback? onAction}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          // Có nút vẫn tự ẩn sau vài giây.
          persist: false,
          action: action == null
              ? null
              : SnackBarAction(label: action, onPressed: onAction ?? () {}),
        ),
      );
  }

  /// Hộp thoại hỏi lại trước khi làm việc khó hoàn tác (đăng xuất, xoá...).
  /// Trả về true nếu người dùng bấm [confirmLabel].
  Future<bool> confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final ok = await showDialog<bool>(
      context: this,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: AppColors.danger)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}
