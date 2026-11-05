import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/feedback.dart';
import '../core/theme.dart';
import '../data/app_state.dart';
import '../l10n/l10n.dart';
import 'layout.dart';

/// Danh sách cuộn dọc có phân trang và kéo để làm mới.
///
/// - Cuộn gần tới cuối → vòng xoay nhỏ ở dưới, tải thêm 1 trang.
///   Hết trang thì thôi; tải lỗi → nút "Retry".
/// - Kéo xuống ở đầu danh sách → làm mới, quay về trang đầu.
/// - Không có mục nào → hiện [empty].
///
/// 2 cách dùng:
/// - Dữ liệu từ server: truyền [onLoadMore], [hasMore], [onRefresh].
///   [itemCount] là số mục đã tải về.
/// - Dữ liệu có sẵn trong máy: chỉ truyền [itemCount], danh sách tự hiện
///   dần mỗi lần [pageSize] mục.
class PagedList extends StatefulWidget {
  const PagedList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.onRefresh,
    this.pageSize = defaultPageSize,
    this.padding,
    this.spacing = 16,
    this.empty,
  });

  static const defaultPageSize = 10;

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Tải trang tiếp từ server; lỗi thì ném ra (hiện nút "Retry").
  final Future<void> Function()? onLoadMore;
  final bool hasMore;

  /// Tải lại từ đầu; null → `AppState.refresh`.
  final RefreshCallback? onRefresh;

  final int pageSize;
  final EdgeInsetsGeometry? padding;

  /// Khoảng cách giữa 2 mục.
  final double spacing;
  final Widget? empty;

  @override
  State<PagedList> createState() => _PagedListState();
}

class _PagedListState extends State<PagedList> {
  final _scroll = ScrollController();
  late int _shown = widget.pageSize; // chỉ dùng khi dữ liệu có sẵn
  var _loading = false;
  var _failed = false;

  /// Còn cách cuối danh sách chừng này thì tải trang tiếp.
  static const _threshold = 300.0;

  bool get _remote => widget.onLoadMore != null;

  int get _count =>
      _remote ? widget.itemCount : math.min(_shown, widget.itemCount);

  bool get _hasMore => _remote ? widget.hasMore : _shown < widget.itemCount;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Gần cuối danh sách (hoặc trang đầu chưa đầy màn hình) → tải tiếp.
  /// Vừa lỗi thì chờ người dùng bấm "Retry".
  void _check() {
    if (_failed || !_scroll.hasClients) return;
    if (_scroll.position.extentAfter < _threshold) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      if (_remote) {
        await widget.onLoadMore!();
      } else {
        await AppScope.read(context).loadPage();
        _shown += widget.pageSize;
      }
    } catch (_) {
      _failed = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    try {
      await (widget.onRefresh ?? AppScope.read(context).refresh)();
      if (!mounted) return;
      setState(() {
        _shown = widget.pageSize;
        _failed = false;
      });
    } catch (_) {
      if (mounted) context.toast(context.l10n.couldntRefresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sau khi vẽ: trang đầu ngắn hơn màn hình thì tải tiếp luôn.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _check();
    });
    final count = _count;
    final empty = widget.itemCount == 0 && !_hasMore;
    // Ô cuối: vòng xoay / nút thử lại khi còn trang, hoặc trạng thái rỗng.
    final footer = _hasMore || (empty && widget.empty != null);
    return AppRefresh(
      onRefresh: _refresh,
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (_) {
          _check();
          return false;
        },
        child: ListView.separated(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: widget.padding,
          itemCount: count + (footer ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: widget.spacing),
          itemBuilder: (context, i) {
            if (i < count) return widget.itemBuilder(context, i);
            if (empty) return widget.empty!;
            return _failed ? _retry() : _spinner();
          },
        ),
      ),
    );
  }

  Widget _spinner() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Center(
      child: Semantics(
        label: context.l10n.loadingMore,
        child: const CircularProgressIndicator.adaptive(),
      ),
    ),
  );

  Widget _retry() => Column(
    children: [
      Text(
        context.l10n.couldntLoadMore,
        style: AppText.body(color: AppColors.grey),
      ),
      TextButton(onPressed: _loadMore, child: Text(context.l10n.retry)),
    ],
  );
}
