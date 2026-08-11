import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

/// 'https://'처럼 실제로 스킴이 붙어 있는지 확인하고 그 스킴을 뽑아낸다.
///
/// [Uri.hasScheme]을 쓰지 않는 이유: Dart는 'exam-archive.kr:8080/path'의
/// 'exam-archive.kr'까지 스킴으로 인정하기 때문에, 포트가 붙은 주소에
/// https를 붙이지 못하고 그대로 열려다 실패한다.
final RegExp _schemePattern = RegExp(r'^([a-zA-Z][a-zA-Z0-9+.\-]*)://');

/// 저장된 주소를 실제로 열 수 있는 [Uri]로 바꾼다.
/// 'exam-archive.kr/...'처럼 스킴이 없으면 https를 붙인다.
///
/// 열 수 없는 주소면 null. 주소는 서버에서 내려오는 값이므로, 웹 주소가
/// 아닌 스킴('file://', 커스텀 앱 스킴 등)은 그대로 실행하지 않는다.
Uri? resolveMaterialUrl(String url) {
  final RegExpMatch? match = _schemePattern.firstMatch(url);
  if (match == null) return Uri.tryParse('https://$url');

  final String scheme = match.group(1)!.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return null;
  return Uri.tryParse(url);
}

/// 자료의 주소를 보여주고 브라우저로 열어주는 카드.
class MaterialLinkCard extends StatelessWidget {
  final String url;

  const MaterialLinkCard({super.key, required this.url});

  Future<void> _open(BuildContext context) async {
    final Uri? uri = resolveMaterialUrl(url);
    bool opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (opened || !context.mounted) return;
    CustomSnackbar.show(
      context,
      message: '링크를 열지 못했어요',
      type: SnackbarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.space1),
          Expanded(
            child: Text(
              url,
              style: AppTextStyle.subText.copyWith(
                fontSize: 13,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.space1),
          GestureDetector(
            onTap: () => _open(context),
            behavior: HitTestBehavior.opaque,
            child: Text(
              '열기',
              style: AppTextStyle.mainText.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
