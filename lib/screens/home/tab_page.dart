import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/headers.dart';

/// Khung chung của 1 tab ở màn Home: đầu trang có tiêu đề, nội dung cuộn,
/// chừa chỗ cho thanh điều hướng nổi.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientHeader(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.semibold(20),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              FloatingNavBar.scrollPadding(context),
            ),
            children: children,
          ),
        ),
      ],
    );
  }
}
