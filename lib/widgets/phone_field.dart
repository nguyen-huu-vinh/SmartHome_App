import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../data/country.dart';
import 'app_text_field.dart';
import 'country_picker.dart';
import 'pressable.dart';

/// Ô mã vùng (bấm để chọn nước) + ô nhập số điện thoại (chỉ nhận số).
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.country,
    required this.onCountryChanged,
    this.controller,
    this.textInputAction,
  });

  final Country country;
  final ValueChanged<Country> onCountryChanged;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Pressable(
          onTap: () async {
            final c = await showCountryPicker(context, country);
            if (c != null) onCountryChanged(c);
          },
          semanticLabel: 'Country code ${country.code}, change',
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          decoration: fieldBoxDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: AppSizes.fieldHeight - 1,
            child: Row(
              spacing: 12,
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 18)),
                Text(country.code, style: AppText.medium(14)),
              ],
            ),
          ),
        ),
        Expanded(
          child: AppTextField(
            controller: controller,
            hint: 'Eg, 1234567890',
            keyboardType: TextInputType.phone,
            textInputAction: textInputAction,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }
}
