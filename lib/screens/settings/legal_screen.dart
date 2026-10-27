import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/headers.dart';

/// 1 mục: tiêu đề đánh số + đoạn văn và/hoặc danh sách gạch đầu dòng.
typedef LegalSection = ({String title, String? body, List<String> bullets});

/// Tài liệu pháp lý. Nội dung lấy theo thiết kế (văn bản mẫu của UI Kit) —
/// cần thay bằng văn bản chính thức của app trước khi phát hành.
enum LegalDoc {
  privacy(
    'Privacy Policy',
    'We respect your privacy. This policy outlines how we handle your data '
        'when you visit our product page or download the UI Kit.',
    [
      (
        title: 'Data Collection',
        body:
            'We do not collect any personal data through the UI Kit files '
            'themselves. All purchases and transactions are handled securely '
            'through UI8’s platform.',
        bullets: [],
      ),
      (
        title: 'Analytics',
        body:
            'We may use anonymous traffic analytics (via UI8) to understand '
            'product interest and downloads. No personal information is '
            'tracked or stored.',
        bullets: [],
      ),
      (
        title: 'Communication',
        body:
            'If you contact us for support, we will only use your email for '
            'support purposes and will not share it with third parties.',
        bullets: [],
      ),
      (
        title: 'Security',
        body:
            'All files are delivered through trusted channels (UI8). We '
            'recommend always downloading from official sources to ensure '
            'security and authenticity.',
        bullets: [],
      ),
    ],
  ),
  terms(
    'Terms of Use',
    'Thank you for purchasing Hoome – Smart Home Control App UI Kit. By '
        'downloading or using this UI Kit, you agree to the following terms:',
    [
      (
        title: 'License',
        body:
            'This UI Kit is sold under a commercial license from UI8. You are '
            'granted the right to use the assets in personal or commercial '
            'projects, as per the licensing terms provided by UI8. '
            'Redistribution or resale of the files is strictly prohibited.',
        bullets: [],
      ),
      (
        title: 'Usage',
        body: null,
        bullets: [
          'You may use this kit in unlimited personal or client projects.',
          'You may modify or adapt the design to suit your needs.',
          'You may not resell, repackage, or distribute the source files as '
              'your own product.',
        ],
      ),
      (
        title: 'Ownership',
        body:
            'All rights remain with the original creator. Unauthorized use, '
            'copying, or redistribution of any part of the product without '
            'proper licensing may result in legal action.',
        bullets: [],
      ),
      (
        title: 'Support',
        body:
            'While this is a design asset and does not include coding '
            'support, we’re happy to help with minor usage questions. Reach '
            'out at [your email/contact].',
        bullets: [],
      ),
    ],
  );

  const LegalDoc(this.title, this.intro, this.sections);
  final String title;
  final String intro;
  final List<LegalSection> sections;
}

/// Trang đọc 1 tài liệu pháp lý; chữ bôi đen để chép được.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final text = AppText.body(size: 16).copyWith(height: 1.5);
    final heading = AppText.semibold(16).copyWith(height: 1.5);
    return Scaffold(
      body: Column(
        children: [
          PageHeader(title: doc.title),
          Expanded(
            child: SelectionArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  32,
                  16,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                children: [
                  Text(doc.intro, style: text),
                  for (final (i, s) in doc.sections.indexed) ...[
                    const SizedBox(height: 20),
                    Text('${i + 1}. ${s.title}', style: heading),
                    if (s.body case final body?) Text(body, style: text),
                    for (final b in s.bullets)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 16, child: Text('•', style: text)),
                            Expanded(child: Text(b, style: text)),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
