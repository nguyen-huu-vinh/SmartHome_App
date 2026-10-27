import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Mọi "thông số thiết kế" của app nằm ở file này: màu, kích thước, bóng,
// chuyển động, kiểu chữ. Đổi ở đây là áp dụng cho toàn app — tránh viết
// thẳng mã màu / số đo vào từng màn.

/// Bảng màu chung.
abstract final class AppColors {
  static const brand = Color(0xFF3DB4FF);
  static const dark = Color(0xFF1A1A1F);
  static const grey = Color(0xFF8E8E9A);
  static const disabled = Color(0xFFBEC0C8);

  // Nền & viền.
  static const field = Color(0xFFF4F4F6); // nền ô nhập (secondary/50)
  static const border = Color(0xFFBFC1C9); // viền ô nhập (secondary/200)
  static const line = Color(0xFFE8E8ED); // viền thẻ, đường kẻ
  static const divider = Color(0xFFEFF0F3); // viền dưới đầu trang
  static const surface = Color(0xFFF2F2F4); // nền nút xám, khối phụ
  static const soft = Color(0xFFE9E9EE); // nền công tắc tắt, nút "+"
  static const muted = Color(0xFFD9D9DE); // nền icon "+", vạch chỉ trang
  static const placeholder = Color(0xFFE9EFF5); // nền khi ảnh lỗi

  // Xanh nhạt: nền đầu trang, ô đang chọn / đang nhập.
  static const sky = Color(0xFFE6F5FF);
  static const skyFill = Color(0xFFE8F5FF);
  static const skyLine = Color(0xFF0B74C4);
  static const skyText = Color(0xFF0D4A78);

  // Trạng thái.
  static const success = Color(0xFF1F9D3A); // Connected / Online
  static const danger = Color(0xFFE5252A); // xoá, lỗi
  static const amber = Color(0xFFF5A623); // sao, tia sét, độ sáng
  static const idle = Color(0xFF85878F); // icon chưa chọn
  static const knob = Color(0xFF4A4C55); // núm công tắc khi tắt
}

/// Kích thước theo thiết kế (Figma).
abstract final class AppSizes {
  static const gutter = 16.0; // lề trái/phải của trang
  static const fieldHeight = 44.0;
  static const buttonHeight = 56.0;
  static const radiusS = 12.0; // ô nhập, ô chọn nhỏ
  static const radiusM = 16.0; // nút, thẻ thiết bị
  static const radiusL = 20.0; // thẻ lớn, nhóm cài đặt
  static const radiusSheet = 32.0; // góc trên bảng trượt / khối trắng

  /// Chiều cao cố định [base] (đo theo thiết kế, chữ cỡ thường) tăng theo
  /// cỡ chữ người dùng chọn trong máy → thẻ cao lên thay vì bị tràn chữ.
  static double scaled(BuildContext context, double base) =>
      base * MediaQuery.textScalerOf(context).scale(16) / 16;
}

/// Bóng đổ dùng chung.
abstract final class AppShadows {
  /// Bóng mờ dưới thẻ.
  static const card = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// Bóng rộng hơn cho thẻ nổi bật.
  static const raised = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  /// Đầu trang, ô tìm kiếm.
  static const header = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  /// Thanh điều hướng nổi, bong bóng thiết bị trên radar.
  static const floating = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Nút đang chọn nổi lên khỏi nền.
  static const lifted = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Quầng màu dưới ô icon (VD: icon phòng).
  static List<BoxShadow> glow(Color color, {double blur = 12}) => [
    BoxShadow(
      color: color.withValues(alpha: 0.35),
      blurRadius: blur,
      offset: Offset(0, blur / 3),
    ),
  ];
}

/// Thời lượng + đường cong chuyển động.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 200); // đổi màu, bật/tắt
  static const medium = Duration(milliseconds: 300); // hiện/ẩn, quầng sáng
  static const slow = Duration(milliseconds: 500); // chuyển trang
  static const curve = Curves.easeOutCubic;
}

/// Nền chuyển màu dùng chung.
abstract final class AppGradients {
  /// Xanh nhạt ở trên → trắng; [fadeAt] (0–1) là điểm hết màu xanh.
  static LinearGradient sky([double fadeAt = 1]) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: const [AppColors.sky, Colors.white],
    stops: [0, fadeAt],
  );
}

/// Kiểu chữ dùng chung (font Inter).
///
/// Đậm nhạt phải tạo bằng các hàm ở đây (gọi lại GoogleFonts) chứ không
/// `copyWith(fontWeight: ...)`, vì mỗi độ đậm là 1 file font riêng.
abstract final class AppText {
  static TextStyle get title => semibold(28);

  static TextStyle get subtitle => body(size: 16, color: AppColors.grey);

  static TextStyle get input => GoogleFonts.inter(fontSize: 14);

  static TextStyle get hint => body(color: AppColors.grey);

  static TextStyle get button =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500);

  /// Tiêu đề trang, bảng, mục.
  static TextStyle get heading => semibold(18);

  /// Tên thiết bị / phòng trên thẻ.
  static TextStyle get name => medium(16);

  static TextStyle body({double size = 14, Color color = AppColors.dark}) =>
      GoogleFonts.inter(fontSize: size, color: color);

  static TextStyle medium(double size, {Color color = AppColors.dark}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle semibold(double size, {Color color = AppColors.dark}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bold(
    double size, {
    Color color = AppColors.dark,
    double? height,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color,
    height: height,
  );

  static TextStyle link({double size = 14, Color color = AppColors.brand}) =>
      GoogleFonts.inter(
        fontSize: size,
        color: color,
        decoration: TextDecoration.underline,
        decorationColor: color,
      );
}

/// Giao diện Material của app: các thành phần có sẵn (bảng trượt, hộp thoại,
/// thông báo, công tắc, menu) đã mang màu + bo góc của thiết kế.
ThemeData buildAppTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand),
    textTheme: GoogleFonts.interTextTheme(),
  );
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusL),
  );
  return base.copyWith(
    scaffoldBackgroundColor: Colors.white,
    dividerTheme: const DividerThemeData(color: AppColors.line),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Color(0x66000000),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusSheet),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: rounded,
      titleTextStyle: AppText.semibold(20),
      contentTextStyle: AppText.body(size: 16, color: AppColors.grey),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.dark,
      contentTextStyle: AppText.body(color: Colors.white),
      actionTextColor: AppColors.brand,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      textStyle: AppText.body(size: 16),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.knob,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? AppColors.brand : AppColors.line,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.dark,
        textStyle: AppText.button,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.brand,
      selectionColor: Color(0x553DB4FF),
      selectionHandleColor: AppColors.brand,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.dark,
    ),
  );
}
