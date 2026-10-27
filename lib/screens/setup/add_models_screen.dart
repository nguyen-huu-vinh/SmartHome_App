import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/device.dart';
import '../../data/device_category.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_image.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/large_title_page.dart';
import '../../widgets/layout.dart';
import '../../widgets/search_box.dart';
import 'adding_device_screen.dart';
import 'scan_devices_screen.dart';

/// Chọn (nhiều) mẫu thiết bị trong 1 loại rồi bấm Add → gán vào phòng.
class AddModelsScreen extends StatefulWidget {
  const AddModelsScreen({super.key, required this.category});

  final DeviceCategory category;

  @override
  State<AddModelsScreen> createState() => _AddModelsScreenState();
}

class _AddModelsScreenState extends State<AddModelsScreen> {
  String _query = '';
  final _picked = <Device>{};

  void _toggle(Device d) => setState(() {
    if (!_picked.remove(d)) _picked.add(d);
  });

  /// Ghép nối lần lượt từng mẫu đã chọn, xong sang gán phòng.
  void _add() => Navigator.push(
    context,
    smoothRoute(
      AddingDeviceScreen(
        devices: [
          for (final d in widget.category.models)
            if (_picked.contains(d)) d,
        ],
      ),
    ),
  );

  /// Về màn quét nếu có trong lịch sử, không thì về màn đầu.
  void _scanNearby() => Navigator.popUntil(
    context,
    (r) => r.settings.name == ScanDevicesScreen.route || r.isFirst,
  );

  @override
  Widget build(BuildContext context) {
    final name = widget.category.name;
    final q = _query.trim().toLowerCase();
    final items = [
      for (final d in widget.category.models)
        if (d.name.toLowerCase().contains(q)) d,
    ];
    return LargeTitlePage(
      title: 'Add ',
      titleExtra: [
        TextSpan(
          text: name,
          style: const TextStyle(color: AppColors.brand),
        ),
      ],
      subtitle:
          'Pick one or more models below. Keep your device close by to pair '
          'it quickly.',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          PrimaryButton(
            label: _picked.length > 1 ? 'Add (${_picked.length})' : 'Add',
            onPressed: _picked.isEmpty ? null : _add,
          ),
          AuthFooter(
            text: 'Missed a device? ',
            link: 'Scan nearby devices',
            onTap: _scanNearby,
          ),
        ],
      ),
      children: [
        SearchBox(
          hint: 'Search $name',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 20),
        if (items.isEmpty)
          EmptyState(
            icon: widget.category.models.isEmpty
                ? Icons.inventory_2_outlined
                : Icons.search_off_rounded,
            message: widget.category.models.isEmpty
                ? 'No $name models available yet.'
                : 'No models match “${_query.trim()}”',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 326 / 382, // theo thiết kế
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => _ModelCard(
              key: ObjectKey(items[i]),
              model: items[i],
              selected: _picked.contains(items[i]),
              onTap: () => _toggle(items[i]),
            ),
          ),
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    super.key,
    required this.model,
    required this.selected,
    required this.onTap,
  });

  final Device model;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadow: null,
      selected: selected,
      haptic: true,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
      child: Column(
        spacing: 8,
        children: [
          Expanded(child: AppImage(model.image)),
          Text(
            model.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.semibold(16),
          ),
          AnimatedSwitcher(
            duration: AppMotion.fast,
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              selected ? Icons.check_circle : Icons.check_circle_outline,
              key: ValueKey(selected),
              size: 24,
              color: selected ? AppColors.dark : AppColors.disabled,
            ),
          ),
        ],
      ),
    );
  }
}
