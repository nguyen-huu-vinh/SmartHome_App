import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/sample_data.dart';
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
      title: 'Add Devices',
      subtitle:
          'Choose a device type below. Keep your device close by to pair '
          'it quickly.',
      children: [
        SearchBox(
          hint: 'Search Devices',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 20),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            message: 'No devices match “${_query.trim()}”',
          ),
        for (final c in items)
          Padding(
            key: ValueKey(c.name),
            padding: const EdgeInsets.only(bottom: 16),
            child: ListCard(
              leading: AppImage(c.image),
              title: c.name,
              subtitle: '${c.count} Devices',
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
