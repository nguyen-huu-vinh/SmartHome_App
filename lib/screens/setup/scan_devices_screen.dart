import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/device.dart';
import '../../data/sample_data.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_image.dart';
import '../../widgets/home_switcher_header.dart';
import '../../widgets/list_card.dart';
import 'add_devices_screen.dart';
import 'manage_rooms_screen.dart';

/// Tìm thiết bị gần đây qua Bluetooth / Wi-Fi.
/// Header cho phép chọn nhà trong các nhà đã tạo.
/// Bấm "Allow and Continue" → radar chuyển xanh, thiết bị lần lượt hiện ra.
class ScanDevicesScreen extends StatefulWidget {
  const ScanDevicesScreen({super.key});

  /// Tên route, dùng để quay lại màn này từ các màn sau.
  static const route = 'scan-devices';

  @override
  State<ScanDevicesScreen> createState() => _ScanDevicesScreenState();
}

/// idle: chưa quét · found: đang tìm thiết bị · connecting: đang kết nối
/// · done: đã thử nối hết, hiện "Found N Devices".
enum _Phase { idle, found, connecting, done }

enum _Link { connecting, connected, failed }

class _ScanDevicesScreenState extends State<ScanDevicesScreen>
    with SingleTickerProviderStateMixin {
  late final _sweep = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();
  var _phase = _Phase.idle;
  final _found = <Device>[];

  /// Thiết bị đã bắt đầu kết nối, mới nhất ở đầu danh sách.
  final _linking = <Device>[];
  final _status = <Device, _Link>{};
  Timer? _timer;

  /// Giả lập: thiết bị này lỗi ở lần nối đầu, bấm thử lại thì được.
  static final _flaky = SampleData.nearby[2];
  final _retried = <Device>{};

  static const _nearby = SampleData.nearby;
  static const _linkDelay = Duration(milliseconds: 1200);

  @override
  void dispose() {
    _timer?.cancel();
    _sweep.dispose();
    super.dispose();
  }

  // TODO: thay bằng xin quyền + quét Bluetooth / Wi-Fi thật.
  void _scan() {
    setState(() => _phase = _Phase.found);
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (_found.length == _nearby.length) return t.cancel();
      setState(() => _found.add(_nearby[_found.length]));
    });
  }

  /// Kết quả giả lập của 1 lần nối.
  _Link _attempt(Device d) =>
      d == _flaky && !_retried.contains(d) ? _Link.failed : _Link.connected;

  // TODO: thay bằng kết nối thật. Mỗi nhịp: thiết bị đang nối → có kết quả,
  // hoặc bắt đầu nối thiết bị kế tiếp. Hết thiết bị → done.
  void _connect() {
    _timer?.cancel();
    setState(() => _phase = _Phase.connecting);
    void tick() {
      final pending = _linking.where((d) => _status[d] == _Link.connecting);
      setState(() {
        if (pending.isNotEmpty) {
          _status[pending.first] = _attempt(pending.first);
        } else if (_linking.length < _found.length) {
          final d = _found[_linking.length];
          _linking.insert(0, d);
          _status[d] = _Link.connecting;
        } else {
          _timer?.cancel();
          _phase = _Phase.done;
        }
      });
    }

    tick();
    _timer = Timer.periodic(_linkDelay, (_) => tick());
  }

  void _retry(Device d) {
    setState(() {
      _retried.add(d);
      _status[d] = _Link.connecting;
    });
    Future.delayed(_linkDelay, () {
      if (mounted) setState(() => _status[d] = _attempt(d));
    });
  }

  /// Sang gán thiết bị đã kết nối vào phòng.
  void _toRooms() => Navigator.push(
    context,
    smoothRoute(
      ManageRoomsScreen(
        devices: [
          for (final d in _found)
            if (_status[d] == _Link.connected) d,
        ],
      ),
    ),
  );

  /// Dừng quét và quay về trạng thái ban đầu.
  void _stop() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.idle;
      _found.clear();
      _linking.clear();
      _status.clear();
      _retried.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final listing = _phase == _Phase.connecting || _phase == _Phase.done;
    return Scaffold(
      // Lúc hiện danh sách thiết bị: nút ghim dưới đáy, không bị đẩy khỏi màn.
      bottomNavigationBar: listing
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  child: _phase == _Phase.done
                      ? PrimaryButton(
                          key: const ValueKey('continue'),
                          label: 'Continue',
                          onPressed: _toRooms,
                        )
                      : GreyButton(
                          key: const ValueKey('stop'),
                          label: 'Stop Scanning',
                          onPressed: _stop,
                        ),
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          HomeSwitcherHeader(
            homes: app.homes,
            index: app.homeIndex,
            onChanged: app.selectHome,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: !listing,
              child: listing ? _listBody() : _introBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _radar() => _Radar(
    sweep: _sweep,
    active: _phase != _Phase.idle,
    devices: _found,
    failed: {
      for (final e in _status.entries)
        if (e.value == _Link.failed) e.key,
    },
  );

  /// Chưa kết nối: cả trang cuộn khi màn nhỏ không đủ chỗ;
  /// màn đủ lớn → radar giãn hết phần trống.
  Widget _introBody() => LayoutBuilder(
    builder: (_, box) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: box.maxHeight - 16),
        child: IntrinsicHeight(
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 180),
                  child: _radar(),
                ),
              ),
              ..._titles(),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Allow and Continue',
                onPressed: switch (_phase) {
                  _Phase.idle => _scan,
                  _ => _found.isEmpty ? null : _connect,
                },
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                label: 'Add Manually',
                onPressed: () => Navigator.push(
                  context,
                  smoothRoute(const AddDevicesScreen()),
                ),
              ),
              const SizedBox(height: 24),
              const Spacer(flex: 2),
              Text(
                'Make sure you have one or more smart devices that support '
                'Wi-Fi or Bluetooth',
                textAlign: TextAlign.center,
                style: AppText.body(size: 16, color: AppColors.grey),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// Đang/đã kết nối: radar + tiêu đề đứng yên, chỉ danh sách thiết bị cuộn,
  /// nút ghim ở đáy (bottomNavigationBar).
  Widget _listBody() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        Expanded(flex: 4, child: _radar()),
        ..._titles(),
        const SizedBox(height: 24),
        Expanded(
          flex: 5,
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: _linking.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final d = _linking[i];
              return _DeviceCard(
                key: ObjectKey(d),
                device: d,
                status: _status[d]!,
                onRetry: () => _retry(d),
              );
            },
          ),
        ),
      ],
    ),
  );

  List<Widget> _titles() => [
    const SizedBox(height: 16),
    Text.rich(switch (_phase) {
      _Phase.connecting => const TextSpan(text: 'Searching...'),
      _Phase.done => TextSpan(
        children: [
          const TextSpan(text: 'Found '),
          TextSpan(
            text: '${_found.length}',
            style: const TextStyle(color: AppColors.brand),
          ),
          TextSpan(text: _found.length == 1 ? ' Device' : ' Devices'),
        ],
      ),
      _ => const TextSpan(text: 'Search Devices'),
    }, style: AppText.bold(28)),
    const SizedBox(height: 8),
    Text(
      switch (_phase) {
        _Phase.connecting =>
          'Please make sure all your devices are connected to Wi-Fi or '
              'Bluetooth',
        _Phase.done => 'Can’t see your device? Please scan again',
        _ => 'Allow us to check nearby devices with Bluetooth or Wi-Fi',
      },
      textAlign: TextAlign.center,
      style: AppText.body(size: 16, color: AppColors.grey),
    ),
  ];
}

/// Thẻ thiết bị: ảnh, tên, trạng thái kết nối, nút thử lại khi lỗi.
class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    super.key,
    required this.device,
    required this.status,
    required this.onRetry,
  });

  final Device device;
  final _Link status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DeviceTile(
      device: device,
      status: switch (status) {
        _Link.connecting => 'Connecting...',
        _Link.connected => 'Connected',
        _Link.failed => 'Unable to connect',
      },
      statusColor: switch (status) {
        _Link.connecting => AppColors.brand,
        _Link.connected => AppColors.dark,
        _Link.failed => AppColors.danger,
      },
      trailing: switch (status) {
        _Link.failed => IconButton(
          onPressed: onRetry,
          tooltip: 'Retry',
          icon: const Icon(Icons.sync, color: AppColors.dark),
        ),
        _Link.connecting => const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        _Link.connected => const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
        ),
      },
    );
  }
}

/// Radar + các thiết bị tìm thấy xếp quanh tâm.
class _Radar extends StatelessWidget {
  const _Radar({
    required this.sweep,
    required this.active,
    required this.devices,
    this.failed = const {},
  });

  final Animation<double> sweep;
  final bool active;
  final List<Device> devices;

  /// Thiết bị nối lỗi → viền đỏ + dấu "!".
  final Set<Device> failed;

  /// Vị trí (theo bội số bán kính radar, tính từ tâm) và đường kính
  /// của từng ô thiết bị — lấy theo thiết kế.
  static const _slots = [
    (Offset(0.68, 0.40), 0.45), // nhỏ, dưới-phải
    (Offset(-0.83, -0.37), 0.68),
    (Offset(0.66, -0.68), 0.68),
    (Offset(-0.35, 0.63), 0.68),
  ];

  @override
  Widget build(BuildContext context) {
    // Không dùng LayoutBuilder vì màn cha bọc IntrinsicHeight.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Màu xám → xanh khi bắt đầu quét.
        TweenAnimationBuilder<double>(
          tween: Tween(end: active ? 1 : 0),
          duration: AppMotion.slow,
          builder: (_, tint, _) => AnimatedBuilder(
            animation: sweep,
            builder: (_, _) => CustomPaint(
              size: Size.infinite,
              painter: _RadarPainter(sweep.value, tint),
            ),
          ),
        ),
        for (var i = 0; i < devices.length; i++)
          Positioned.fill(
            key: ObjectKey(devices[i]),
            child: CustomSingleChildLayout(
              delegate: _SlotLayout(_slots[i % _slots.length]),
              child: _bubble(devices[i]),
            ),
          ),
      ],
    );
  }

  Widget _bubble(Device d) {
    final isFailed = failed.contains(d);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Tooltip(
        message: d.name,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedContainer(
              duration: AppMotion.medium,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: isFailed
                    ? Border.all(color: AppColors.danger, width: 1.5)
                    : Border.all(color: AppColors.line),
                boxShadow: AppShadows.floating,
              ),
              child: ClipOval(child: AppImage(d.image, fit: BoxFit.cover)),
            ),
            if (isFailed)
              Positioned(
                bottom: -8,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: AppColors.danger,
                  child: Text(
                    '!',
                    style: AppText.bold(12, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Đặt 1 ô thiết bị theo [slot] = (vị trí, đường kính) tính theo bán kính radar.
class _SlotLayout extends SingleChildLayoutDelegate {
  _SlotLayout(this.slot);

  final (Offset, double) slot;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.tight(
        Size.square(slot.$2 * _RadarPainter.radiusFor(constraints.biggest)),
      );

  @override
  Offset getPositionForChild(Size size, Size child) =>
      size.center(Offset.zero) +
      slot.$1 * _RadarPainter.radiusFor(size) -
      child.center(Offset.zero);

  @override
  bool shouldRelayout(_SlotLayout old) => old.slot != slot;
}

/// Radar: 2 vòng tròn đồng tâm, chữ thập, và 1/4 vòng quét xoay quanh tâm.
/// [tint] 0 = xám (chưa quét), 1 = xanh (đang quét).
class _RadarPainter extends CustomPainter {
  _RadarPainter(this.turn, this.tint);

  /// 0..1 — một vòng quay.
  final double turn;
  final double tint;

  /// Đường chữ thập dài hơn vòng ngoài ~10%.
  static double radiusFor(Size size) =>
      math.min(size.width * 0.7, size.height / 1.1) / 2;

  Color _c(int grey, int blue) => Color.lerp(Color(grey), Color(blue), tint)!;

  @override
  void paint(Canvas canvas, Size size) {
    final r = radiusFor(size);
    final c = size.center(Offset.zero);
    final inner = r * 0.53;
    final line = r * 1.1;

    void circle(double radius, Color fill, Color stroke) {
      canvas.drawCircle(c, radius, Paint()..color = fill);
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke,
      );
    }

    circle(r, _c(0xFFF5F5F6, 0xFFEAF6FF), _c(0xFFE6E6EA, 0xFFEAF6FF));
    circle(inner, _c(0xFFEFEFF2, 0xFFDDF0FF), _c(0xFFDCDCE0, 0xFFDDF0FF));

    // Vòng quét: bắt đầu ở góc phần tư trên-trái như thiết kế.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: inner),
      math.pi + turn * 2 * math.pi,
      math.pi / 2,
      true,
      Paint()..color = _c(0xFFE2E3E7, 0xFFC4E5FF),
    );

    final p = Paint()..color = _c(0xFFD0D0D6, 0xFFD6EBFA);
    canvas.drawLine(c.translate(-line, 0), c.translate(line, 0), p);
    canvas.drawLine(c.translate(0, -line), c.translate(0, line), p);
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.turn != turn || old.tint != tint;
}
