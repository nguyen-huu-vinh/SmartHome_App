import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/headers.dart';
import '../../widgets/layout.dart';
import '../../widgets/paged_list.dart';

/// Khung chung của 1 tab ở màn Home: đầu trang có tiêu đề, nội dung cuộn,
/// chừa chỗ cho thanh điều hướng nổi, kéo xuống để làm mới.
class TabPage extends StatelessWidget {
  /// Nội dung cố định, hiện hết 1 lần.
  const TabPage({
    super.key,
    required this.title,
    required List<Widget> this.children,
  }) : itemCount = 0,
       itemBuilder = null,
       onLoadMore = null,
       hasMore = false,
       onRefresh = null,
       empty = null;

  /// Danh sách dài, phân trang (xem [PagedList]).
  const TabPage.paged({
    super.key,
    required this.title,
    required this.itemCount,
    required IndexedWidgetBuilder this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.onRefresh,
    this.empty,
  }) : children = null;

  final String title;
  final List<Widget>? children;
  final int itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final RefreshCallback? onRefresh;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.fromLTRB(
      16,
      16,
      16,
      FloatingNavBar.scrollPadding(context),
    );
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
          child: itemBuilder == null
              ? AppRefresh(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: padding,
                    children: children!,
                  ),
                )
              : PagedList(
                  padding: padding,
                  itemCount: itemCount,
                  itemBuilder: itemBuilder!,
                  onLoadMore: onLoadMore,
                  hasMore: hasMore,
                  onRefresh: onRefresh,
                  empty: empty,
                ),
        ),
      ],
    );
  }
}
