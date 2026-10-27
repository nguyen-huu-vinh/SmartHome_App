import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/device.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_image.dart';
import '../../widgets/headers.dart';
import 'manage_rooms_screen.dart';

/// Các bước ghép nối 1 thiết bị: Bluetooth → Wi-Fi → xong.
enum _Step { bluetooth, wifi, done }

/// Ghép nối lần lượt từng thiết bị trong [devices], xong hết thì
/// thay bằng màn gán phòng (bấm quay lại sẽ không về màn này nữa).
class AddingDeviceScreen extends StatefulWidget {
  const AddingDeviceScreen({super.key, required this.devices});

  final List<Device> devices;

  @override
  State<AddingDeviceScreen> createState() => _AddingDeviceScreenState();
}

class _AddingDeviceScreenState extends State<AddingDeviceScreen> {
  static const _stepDelay = Duration(milliseconds: 1200);

  int _index = 0;
  var _step = _Step.bluetooth;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_stepDelay, (_) => _next());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // TODO: thay bằng ghép nối Bluetooth + cấu hình Wi-Fi thật.
  void _next() {
    if (_step != _Step.done) {
      setState(() => _step = _Step.values[_step.index + 1]);
    } else if (_index < widget.devices.length - 1) {
      setState(() {
        _index++;
        _step = _Step.bluetooth;
      });
    } else {
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        smoothRoute(ManageRoomsScreen(devices: widget.devices)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.devices[_index];
    final total = widget.devices.length;
    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            padding: EdgeInsets.fromLTRB(16, 40, 16, 72),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppBackButton(),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                // Đổi thiết bị → mờ dần sang thiết bị kế tiếp.
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    key: ObjectKey(device),
                    children: [
                      Flexible(
                        flex: 3,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 240),
                          child: AppImage(device.image),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        device.name,
                        textAlign: TextAlign.center,
                        style: AppText.bold(28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _step == _Step.done
                            ? 'Added to your home'
                            : total > 1
                            ? 'Adding to your home (${_index + 1}/$total)'
                            : 'Adding to your home',
                        style: AppText.body(size: 16, color: AppColors.grey),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 32,
                        children: [
                          _Signal(
                            icon: Icons.bluetooth_rounded,
                            label: 'Bluetooth',
                            active: _step == _Step.bluetooth,
                            done: _step.index > _Step.bluetooth.index,
                          ),
                          _Signal(
                            icon: Icons.wifi_rounded,
                            label: 'Wi-Fi',
                            active: _step == _Step.wifi,
                            done: _step == _Step.done,
                          ),
                        ],
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon kết nối: đang chạy → xanh nhấp nháy, xong → xanh, chưa tới → tối.
class _Signal extends StatefulWidget {
  const _Signal({
    required this.icon,
    required this.label,
    required this.active,
    required this.done,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool done;

  @override
  State<_Signal> createState() => _SignalState();
}

class _SignalState extends State<_Signal> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    lowerBound: 0.35,
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Signal old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.active) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lit = widget.active || widget.done;
    return Semantics(
      label:
          '${widget.label} ${widget.done
              ? 'connected'
              : widget.active
              ? 'connecting'
              : 'waiting'}',
      child: FadeTransition(
        opacity: _pulse,
        child: Icon(
          widget.icon,
          size: 28,
          color: lit ? AppColors.brand : AppColors.dark,
        ),
      ),
    );
  }
}
