import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/badges.dart';
import '../../widgets/dashed_box.dart';
import '../../widgets/large_title_page.dart';
import 'scan_devices_screen.dart';

/// Tạo / quản lý danh sách nhà.
/// Chưa có nhà → "Create Home", nút Continue xám.
/// Đã có nhà → "Manage Homes", mỗi nhà là 1 ô nhập tên, có nút xoá.
class ManageHomesScreen extends StatefulWidget {
  const ManageHomesScreen({super.key});

  @override
  State<ManageHomesScreen> createState() => _ManageHomesScreenState();
}

class _ManageHomesScreenState extends State<ManageHomesScreen> {
  static const _tileHeight = 48.0;

  final _homes = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    // Quay lại màn này (VD: đăng nhập lại) → hiện các nhà đã tạo.
    final app = AppScope.read(context);
    if (app.hasHomes) {
      _homes.addAll([
        for (final name in app.homes) TextEditingController(text: name),
      ]);
    }
  }

  @override
  void dispose() {
    for (final c in _homes) {
      c.dispose();
    }
    super.dispose();
  }

  void _add() => setState(() => _homes.add(TextEditingController()));

  void _remove(TextEditingController c) {
    setState(() => _homes.remove(c));
    c.dispose();
  }

  void _continue() {
    // Ô chưa đặt tên → "Home 1", "Home 2", ...
    final names = [
      for (var i = 0; i < _homes.length; i++)
        _homes[i].text.trim().isEmpty ? 'Home ${i + 1}' : _homes[i].text.trim(),
    ];
    AppScope.read(context).setHomes(names);
    Navigator.push(
      context,
      smoothRoute(const ScanDevicesScreen(), name: ScanDevicesScreen.route),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empty = _homes.isEmpty;
    return LargeTitlePage(
      title: empty ? 'Create Home' : 'Manage Homes',
      subtitle: 'Here you can add, update or delete your homes',
      children: [
        if (empty)
          _addTile()
        else
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: _tileHeight,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _homes.length + 1,
            itemBuilder: (_, i) =>
                i < _homes.length ? _homeTile(_homes[i]) : _addTile(),
          ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Continue', onPressed: empty ? null : _continue),
      ],
    );
  }

  Widget _addTile() =>
      AddTile(label: 'Add Home', height: _tileHeight, onTap: _add);

  Widget _homeTile(TextEditingController c) => Container(
    key: ObjectKey(c),
    padding: const EdgeInsets.only(left: 12, right: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.line),
      borderRadius: BorderRadius.circular(AppSizes.radiusS),
    ),
    child: Row(
      children: [
        const HomeWifiIcon(),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: c,
            autofocus: c.text.isEmpty,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: AppText.body(size: 16),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Home Name',
              hintStyle: AppText.body(size: 16, color: AppColors.grey),
            ),
          ),
        ),
        // Nút xoá có sẵn lề vùng bấm 8 (cũng là khoảng cách với chữ).
        RemoveBadge(label: 'Remove home', onTap: () => _remove(c)),
      ],
    ),
  );
}
