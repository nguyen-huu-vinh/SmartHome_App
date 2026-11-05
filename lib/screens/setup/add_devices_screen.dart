import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/sample_data.dart';
import '../../l10n/l10n.dart';
import '../../widgets/app_image.dart';
import '../../widgets/large_title_page.dart';
import '../../widgets/layout.dart';
import '../../widgets/list_card.dart';
import '../../widgets/search_box.dart';
import 'add_models_screen.dart';

/// Thêm thiết bị thủ công: tìm và chọn loại thiết bị.
class AddDevicesScreen extends StatefulWidget {
  const AddDevicesScreen({super.key});

  @override
  State<AddDevicesScreen> createState() => _AddDevicesScreenState();
}

class _AddDevicesScreenState extends State<AddDevicesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final items = [
      for (final c in SampleData.categories)
        if (c.name.toLowerCase().contains(q)) c,
    ];
    return LargeTitlePage(
      title: context.l10n.addDevices,
      subtitle: context.l10n.chooseDeviceType,
      children: [
        SearchBox(
          hint: context.l10n.searchDevices,
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 20),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            message: context.l10n.noDevicesMatch(_query.trim()),
          ),
        for (final c in items)
          Padding(
            key: ValueKey(c.name),
            padding: const EdgeInsets.only(bottom: 16),
            child: ListCard(
              leading: AppImage(c.image),
              title: c.name,
              subtitle: context.l10n.devicesCountText(c.count),
              trailing: const Icon(
                Icons.arrow_right,
                size: 32,
                color: AppColors.grey,
              ),
              onTap: () => Navigator.push(
                context,
                smoothRoute(AddModelsScreen(category: c)),
              ),
            ),
          ),
      ],
    );
  }
}
