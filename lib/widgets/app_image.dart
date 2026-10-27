import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Ảnh trong assets. Thiếu file / sai đường dẫn → ô xám có icon thay vì lỗi.
class AppImage extends StatelessWidget {
  const AppImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final String path;
  final double? width, height;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(
          color: AppColors.placeholder,
          child: Center(
            child: Icon(Icons.image_outlined, color: AppColors.disabled),
          ),
        ),
      ),
    );
  }
}
