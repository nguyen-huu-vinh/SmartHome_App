import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Mở bảng trượt từ dưới lên theo kiểu chung của app (nền trắng, bo góc trên
/// — xem `bottomSheetTheme`). Bảng cao tự cuộn, không đè lên thanh trạng thái.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: builder,
);

/// Đầu bảng trượt: [leading] (nếu có), tiêu đề + dòng phụ / [status], nút đóng.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.status,
    this.leading,
  });

  final String title;

  /// Dòng chữ xám dưới tiêu đề (VD: "3 Devices").
  final String? subtitle;

  /// Dòng tuỳ ý dưới tiêu đề, thay cho [subtitle] (VD: "● Connected 23%").
  final Widget? status;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final status = this.status;
    final twoLines = subtitle != null || status != null;
    return Row(
      crossAxisAlignment: twoLines
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      spacing: 12,
      children: [
        ?leading,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(title, style: AppText.heading),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppText.body(size: 16, color: AppColors.grey),
                ),
              ?status,
            ],
          ),
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.dark),
        ),
      ],
    );
  }
}
