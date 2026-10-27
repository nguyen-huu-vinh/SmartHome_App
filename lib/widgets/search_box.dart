import 'package:flutter/material.dart';

import '../core/feedback.dart';
import '../core/theme.dart';

/// Ô tìm kiếm nền trắng, bóng nhẹ. Đang có chữ → nút xoá nhanh;
/// chưa có chữ → nút mic.
class SearchBox extends StatefulWidget {
  const SearchBox({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  final String hint;
  final ValueChanged<String> onChanged;

  /// Truyền vào nếu màn cha cần tự xoá / đọc chữ.
  final TextEditingController? controller;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController? _own;
  TextEditingController get _text =>
      widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _clear() {
    _text.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.header,
      ),
      child: TextField(
        controller: _text,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: AppText.body(size: 16),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppText.body(size: 16, color: AppColors.disabled),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.search_rounded, color: AppColors.disabled),
          ),
          prefixIconConstraints: const BoxConstraints(),
          suffixIcon: ListenableBuilder(
            listenable: _text,
            builder: (context, _) => _text.text.isEmpty
                ? IconButton(
                    tooltip: 'Voice search',
                    // TODO: tìm bằng giọng nói.
                    onPressed: () =>
                        context.toast('Voice search is coming soon'),
                    icon: const Icon(
                      Icons.mic_none_rounded,
                      color: AppColors.dark,
                    ),
                  )
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: _clear,
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: AppColors.disabled,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
