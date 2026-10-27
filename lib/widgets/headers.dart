import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'app_buttons.dart';

/// Đầu trang nền xanh nhạt → trắng, viền dưới mảnh (Home, các tab, ...).
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.sky(),
        border: const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Đầu trang trắng có bóng: nút quay lại, [leading] (VD: icon phòng),
/// tiêu đề + dòng phụ, [actions] bên phải (VD: menu "...").
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.titleSize = 18,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
        boxShadow: AppShadows.header,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          // Nút ở cuối đã có lề riêng.
          padding: EdgeInsets.fromLTRB(16, 12, actions.isEmpty ? 16 : 4, 12),
          child: Row(
            spacing: 14,
            children: [
              const AppBackButton(),
              ?leading,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.semibold(titleSize),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(
                          size: titleSize > 18 ? 16 : 14,
                          color: AppColors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
