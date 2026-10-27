import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'app_buttons.dart';
import 'app_card.dart';
import 'app_icons.dart';
import 'app_sheet.dart';
import 'badges.dart';
import 'dashed_box.dart';
import 'name_input_sheet.dart';

/// Kết quả của bảng quản lý nhà: danh sách mới + nhà đang chọn.
typedef HomesResult = ({List<String> homes, int index});

/// Bảng chọn / thêm / xoá nhà. Chỉ áp dụng khi bấm Continue;
/// đóng bằng ✕ hoặc vuốt xuống thì bỏ mọi thay đổi (trả về null).
Future<HomesResult?> showManageHomesSheet(
  BuildContext context, {
  required List<String> homes,
  required int index,
}) => showAppSheet<HomesResult>(
  context,
  builder: (_) => _HomesSheet(homes: homes, index: index),
);

class _HomesSheet extends StatefulWidget {
  const _HomesSheet({required this.homes, required this.index});

  final List<String> homes;
  final int index;

  @override
  State<_HomesSheet> createState() => _HomesSheetState();
}

class _HomesSheetState extends State<_HomesSheet> {
  static const _tileHeight = 48.0;

  late final _homes = [...widget.homes];
  late int _index = widget.index;

  void _remove(int i) => setState(() {
    _homes.removeAt(i);
    // Giữ đúng nhà đang chọn; xoá đúng nhà đó → chọn nhà đầu.
    if (i == _index) {
      _index = 0;
    } else if (i < _index) {
      _index--;
    }
  });

  Future<void> _add() async {
    final name = await showAddHomeSheet(context);
    if (name == null || !mounted) return;
    setState(() {
      _homes.add(name);
      _index = _homes.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Phải còn ít nhất 1 nhà → nhà cuối cùng không có nút xoá.
    final canRemove = _homes.length > 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(title: 'Manage Homes'),
            const SizedBox(height: 12),
            // Nhiều nhà → danh sách cuộn, nút Continue vẫn nằm dưới.
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: _tileHeight,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _homes.length + 1,
                itemBuilder: (_, i) => i < _homes.length
                    ? _HomeTile(
                        name: _homes[i],
                        selected: i == _index,
                        onTap: () => setState(() => _index = i),
                        onRemove: canRemove ? () => _remove(i) : null,
                      )
                    : AddTile(label: 'Add Home', onTap: _add),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Continue',
              onPressed: () =>
                  Navigator.pop(context, (homes: _homes, index: _index)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.name,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  /// null = không cho xoá (nhà cuối cùng).
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final onRemove = this.onRemove;
    return AppCard(
      radius: AppSizes.radiusS,
      color: selected ? AppColors.skyFill : Colors.white,
      selected: selected,
      selectedColor: AppColors.skyLine,
      haptic: true,
      onTap: onTap,
      padding: EdgeInsets.only(left: 12, right: onRemove == null ? 12 : 4),
      child: Row(
        children: [
          HomeWifiIcon(
            color: selected ? AppColors.skyLine : AppColors.muted,
            wifiColor: selected ? Colors.white : AppColors.dark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(
                size: 16,
                color: selected ? AppColors.skyText : AppColors.dark,
              ),
            ),
          ),
          // Nút xoá có sẵn lề vùng bấm 8 (cũng là khoảng cách với chữ).
          if (onRemove != null)
            RemoveBadge(label: 'Remove $name', onTap: onRemove),
        ],
      ),
    );
  }
}
