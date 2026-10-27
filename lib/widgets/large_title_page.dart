import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'app_buttons.dart';
import 'auth_layout.dart';

/// Khung trang có tiêu đề lớn (các bước thiết lập: tạo nhà, thêm thiết bị...):
/// nền xanh nhạt → trắng, nút quay lại, tiêu đề + mô tả, rồi [children]
/// trong 1 danh sách cuộn. [bottom] (nếu có) ghim dưới đáy.
class LargeTitlePage extends StatelessWidget {
  const LargeTitlePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.bottom,
    this.titleExtra = const [],
  });

  final String title;

  /// Phần nối thêm sau [title] (VD: tên loại thiết bị tô màu brand).
  final List<InlineSpan> titleExtra;
  final String subtitle;
  final List<Widget> children;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final bottom = this.bottom;
    return Scaffold(
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: bottom,
              ),
            ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.sky(0.3)),
        child: SafeArea(
          bottom: bottom == null,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(),
              ),
              const SizedBox(height: 24),
              AuthHeader(
                title: title,
                subtitle: subtitle,
                titleExtra: titleExtra,
              ),
              const SizedBox(height: 24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
