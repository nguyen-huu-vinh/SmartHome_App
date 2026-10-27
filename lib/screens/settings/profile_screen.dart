import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/feedback.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/headers.dart';
import '../../widgets/phone_field.dart';

/// Sửa hồ sơ: tên, số điện thoại, email. Update → lưu và quay lại.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final _profile = AppScope.read(context).profile;
  late final _name = TextEditingController(text: _profile.name);
  late final _phone = TextEditingController(text: _profile.phone);
  late final _email = TextEditingController(text: _profile.email);
  late var _country = _profile.country;

  late final _fields = [_name, _phone, _email];
  late final _anyChange = Listenable.merge(_fields);

  @override
  void dispose() {
    for (final c in _fields) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      _email.text.contains('@');

  void _update() {
    AppScope.read(context).updateProfile(
      _profile.copyWith(
        name: _name.text.trim(),
        country: _country,
        phone: _phone.text.trim(),
        email: _email.text.trim(),
      ),
    );
    context.toast('Profile updated');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const PageHeader(title: 'Profile'),
          Expanded(
            child: AutofillGroup(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                children: [
                  AppTextField(
                    controller: _name,
                    hint: 'Your name',
                    prefix: const Icon(
                      Icons.person,
                      color: AppColors.brand,
                      size: 20,
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                  ),
                  const SizedBox(height: 16),
                  PhoneField(
                    controller: _phone,
                    country: _country,
                    onCountryChanged: (c) => setState(() => _country = c),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _email,
                    hint: 'Your email address',
                    prefix: AppIcon.email.widget(20),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 32),
                  ListenableBuilder(
                    listenable: _anyChange,
                    builder: (_, _) => PrimaryButton(
                      label: 'Update',
                      onPressed: _valid ? _update : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
