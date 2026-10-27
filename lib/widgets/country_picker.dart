import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/country.dart';
import 'app_sheet.dart';
import 'pressable.dart';

/// Mở bảng chọn mã vùng, trả về nước được chọn (null nếu đóng mà không chọn).
Future<Country?> showCountryPicker(BuildContext context, Country current) =>
    showAppSheet<Country>(
      context,
      builder: (_) => _CountrySheet(current: current),
    );

class _CountrySheet extends StatelessWidget {
  const _CountrySheet({required this.current});
  final Country current;

  static final _border = Border.all(color: AppColors.border, width: 0.5);

  @override
  Widget build(BuildContext context) {
    final label = AppText.semibold(16);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHeader(title: 'Select Country Code'),
            const SizedBox(height: 12),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: _border,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                spacing: 12,
                children: [
                  Text(current.flag, style: const TextStyle(fontSize: 24)),
                  Text(current.code, style: label),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in Country.all)
                    Pressable(
                      onTap: () => Navigator.pop(context, c),
                      selected: c == current,
                      scale: 0.98,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        spacing: 16,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: _border,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusS,
                              ),
                            ),
                            child: Text(
                              c.flag,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                          Expanded(
                            child: Text('${c.code} - ${c.name}', style: label),
                          ),
                          if (c == current)
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.dark,
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
