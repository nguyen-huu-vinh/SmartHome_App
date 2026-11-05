import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/home_device.dart';
import '../../l10n/l10n.dart';
import '../../widgets/device_cards.dart';
import '../../widgets/headers.dart';
import '../../widgets/paged_list.dart';

/// "View all": toàn bộ thiết bị của 1 nhóm, thẻ giãn hết chiều ngang.
class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key, required this.group});

  final DeviceGroup group;

  @override
  Widget build(BuildContext context) {
    final items = AppScope.of(context).inGroup(group);
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: group.listTitle(context.l10n),
            subtitle: group.count(context.l10n, items.length),
          ),
          Expanded(
            child: PagedList(
              padding: EdgeInsets.fromLTRB(
                16,
                24,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => SizedBox(
                height: AppSizes.scaled(context, deviceCardHeight(group)),
                child: DeviceCard(device: items[i], width: double.infinity),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
