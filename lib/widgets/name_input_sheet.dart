import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'app_buttons.dart';
import 'app_icons.dart';
import 'app_sheet.dart';
import 'app_text_field.dart';

/// Bảng nhập tên phòng mới.
Future<String?> showAddRoomSheet(BuildContext context) => showNameInputSheet(
  context,
  title: 'Add Room',
  hint: 'Room Name',
  icon: const CubeIcon(),
);

/// Bảng nhập tên nhà mới.
Future<String?> showAddHomeSheet(BuildContext context) => showNameInputSheet(
  context,
  title: 'Add Home',
  hint: 'Home Name',
  icon: const HomeWifiIcon(
    size: 22,
    color: AppColors.brand,
    wifiColor: Colors.white,
  ),
);

/// Bảng nhập 1 dòng chữ (tiêu đề, ô nhập có icon, nút cùng tên tiêu đề),
/// nằm ngay trên bàn phím. Trả về chữ đã nhập (null nếu đóng).
/// [action] = chữ trên nút (mặc định là [title]).
Future<String?> showNameInputSheet(
  BuildContext context, {
  required String title,
  required String hint,
  required Widget icon,
  String? action,
  TextCapitalization capitalization = TextCapitalization.words,
}) => showAppSheet<String>(
  context,
  builder: (_) => _NameSheet(
    title: title,
    hint: hint,
    icon: icon,
    action: action ?? title,
    capitalization: capitalization,
  ),
);

class _NameSheet extends StatefulWidget {
  const _NameSheet({
    required this.title,
    required this.hint,
    required this.icon,
    required this.action,
    required this.capitalization,
  });

  final String title, hint, action;
  final Widget icon;
  final TextCapitalization capitalization;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Đẩy bảng lên trên bàn phím.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              SheetHeader(title: widget.title),
              AppTextField(
                hint: widget.hint,
                controller: _name,
                autofocus: true,
                focusedFill: AppColors.skyFill,
                textCapitalization: widget.capitalization,
                textInputAction: TextInputAction.done,
                prefix: widget.icon,
                onSubmitted: (_) => _submit(),
              ),
              // Chưa nhập gì → nút xám.
              ListenableBuilder(
                listenable: _name,
                builder: (_, _) => PrimaryButton(
                  label: widget.action,
                  onPressed: _name.text.trim().isEmpty ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
