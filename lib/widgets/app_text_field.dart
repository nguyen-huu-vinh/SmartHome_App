import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/assets.dart';
import '../core/theme.dart';

/// Nền + viền của ô nhập, dùng chung cho các ô giả dạng ô nhập (vd: mã vùng).
const fieldBoxDecoration = BoxDecoration(
  color: AppColors.field,
  border: Border.fromBorderSide(
    BorderSide(color: AppColors.border, width: 0.5),
  ),
  borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusS)),
);

/// Ô nhập chuẩn theo thiết kế: cao đúng 44, bo 12, viền 0.5 (xanh khi đang
/// nhập). [password] = true sẽ tự có nút ẩn/hiện mật khẩu.
/// [textInputAction] = next → bấm "Next" trên bàn phím sang ô kế tiếp.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.prefix,
    this.password = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.letterSpacing,
    this.autofocus = false,
    this.focusedFill,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  final String hint;
  final TextEditingController? controller;
  final Widget? prefix;
  final bool password;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final int? maxLength;
  final double? letterSpacing;
  final bool autofocus;

  /// Màu nền khi đang nhập (null = giữ nền xám).
  final Color? focusedFill;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focus = FocusNode();
  bool _hide = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefix = widget.prefix;
    final focused = _focus.hasFocus;
    return GestureDetector(
      // Chạm vào icon / lề trong khung cũng bắt đầu nhập.
      onTap: _focus.requestFocus,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        height: AppSizes.fieldHeight,
        decoration: fieldBoxDecoration.copyWith(
          color: focused ? widget.focusedFill : null,
          border: Border.all(
            color: focused ? AppColors.brand : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            if (prefix != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: prefix,
              )
            else
              const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                obscureText: widget.password && _hide,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                autofillHints: widget.autofillHints,
                inputFormatters: widget.inputFormatters,
                textAlign: widget.textAlign,
                maxLength: widget.maxLength,
                autofocus: widget.autofocus,
                textCapitalization: widget.textCapitalization,
                onSubmitted: widget.onSubmitted,
                style: AppText.input.copyWith(
                  letterSpacing: widget.letterSpacing,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: widget.hint,
                  hintStyle: AppText.hint.copyWith(letterSpacing: 0),
                ).copyWith(counterText: ''),
              ),
            ),
            if (widget.password)
              IconButton(
                tooltip: _hide ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _hide = !_hide),
                style: IconButton.styleFrom(
                  fixedSize: const Size.square(40),
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: (_hide ? AppIcon.eyeClosed : AppIcon.eye).widget(20),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
