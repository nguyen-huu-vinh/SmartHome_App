import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/headers.dart';

/// 1 mục: tiêu đề đánh số + đoạn văn và/hoặc danh sách gạch đầu dòng.
typedef LegalSection = ({String title, String? body, List<String> bullets});

/// Tài liệu pháp lý. Nội dung lấy theo thiết kế (văn bản mẫu của UI Kit) —
/// cần thay bằng văn bản chính thức của app trước khi phát hành.
enum LegalDoc {
  privacy,
  terms;

  String title(AppLocalizations l) =>
      this == privacy ? l.privacyPolicy : l.termsOfUse;

  /// Nội dung theo ngôn ngữ (văn bản dài nên không để trong file .arb).
  ({String intro, List<LegalSection> sections}) content(String language) =>
      switch ((this, language)) {
        (privacy, 'vi') => _privacyVi,
        (privacy, _) => _privacyEn,
        (terms, 'vi') => _termsVi,
        (terms, _) => _termsEn,
      };
}

const _privacyEn = (
  intro:
      'We respect your privacy. This policy outlines how we handle your data '
      'when you visit our product page or download the UI Kit.',
  sections: <LegalSection>[
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
);

const _privacyVi = (
  intro:
      'Chúng tôi tôn trọng quyền riêng tư của bạn. Chính sách này mô tả cách '
      'chúng tôi xử lý dữ liệu khi bạn truy cập trang sản phẩm hoặc tải UI Kit.',
  sections: <LegalSection>[
    (
      title: 'Thu thập dữ liệu',
      body:
          'Bản thân các file UI Kit không thu thập bất kỳ dữ liệu cá nhân nào. '
          'Mọi giao dịch mua bán đều được xử lý an toàn qua nền tảng của UI8.',
      bullets: [],
    ),
    (
      title: 'Phân tích',
      body:
          'Chúng tôi có thể dùng số liệu truy cập ẩn danh (qua UI8) để hiểu '
          'mức độ quan tâm và lượt tải sản phẩm. Không có thông tin cá nhân '
          'nào bị theo dõi hay lưu lại.',
      bullets: [],
    ),
    (
      title: 'Liên lạc',
      body:
          'Nếu bạn liên hệ để được hỗ trợ, chúng tôi chỉ dùng email của bạn '
          'cho việc hỗ trợ và không chia sẻ cho bên thứ ba.',
      bullets: [],
    ),
    (
      title: 'Bảo mật',
      body:
          'Mọi file đều được cung cấp qua kênh tin cậy (UI8). Bạn nên luôn tải '
          'từ nguồn chính thức để đảm bảo an toàn và đúng bản gốc.',
      bullets: [],
    ),
  ],
);

const _termsEn = (
  intro:
      'Thank you for purchasing Hoome – Smart Home Control App UI Kit. By '
      'downloading or using this UI Kit, you agree to the following terms:',
  sections: <LegalSection>[
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

const _termsVi = (
  intro:
      'Cảm ơn bạn đã mua Hoome – Smart Home Control App UI Kit. Khi tải về '
      'hoặc sử dụng UI Kit này, bạn đồng ý với các điều khoản sau:',
  sections: <LegalSection>[
    (
      title: 'Giấy phép',
      body:
          'UI Kit này được bán theo giấy phép thương mại của UI8. Bạn được '
          'quyền dùng tài nguyên trong dự án cá nhân hoặc thương mại, theo '
          'điều khoản giấy phép của UI8. Nghiêm cấm phân phối lại hoặc bán '
          'lại các file.',
      bullets: [],
    ),
    (
      title: 'Sử dụng',
      body: null,
      bullets: [
        'Bạn được dùng bộ kit này cho không giới hạn dự án cá nhân hoặc của '
            'khách hàng.',
        'Bạn được chỉnh sửa hoặc điều chỉnh thiết kế theo nhu cầu.',
        'Bạn không được bán lại, đóng gói lại hoặc phân phối file nguồn như '
            'sản phẩm của mình.',
      ],
    ),
    (
      title: 'Quyền sở hữu',
      body:
          'Mọi quyền thuộc về tác giả gốc. Việc sử dụng, sao chép hoặc phân '
          'phối lại bất kỳ phần nào của sản phẩm khi không có giấy phép hợp lệ '
          'có thể bị xử lý theo pháp luật.',
      bullets: [],
    ),
    (
      title: 'Hỗ trợ',
      body:
          'Đây là tài nguyên thiết kế và không kèm hỗ trợ lập trình, nhưng '
          'chúng tôi sẵn lòng giải đáp các câu hỏi nhỏ về cách dùng. Liên hệ '
          'tại [email/liên hệ của bạn].',
      bullets: [],
    ),
  ],
);

/// Trang đọc 1 tài liệu pháp lý; chữ bôi đen để chép được.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final content = doc.content(Localizations.localeOf(context).languageCode);
    final text = AppText.body(size: 16).copyWith(height: 1.5);
    final heading = AppText.semibold(16).copyWith(height: 1.5);
    return Scaffold(
      body: Column(
        children: [
          PageHeader(title: doc.title(context.l10n)),
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
                  Text(content.intro, style: text),
                  for (final (i, s) in content.sections.indexed) ...[
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
