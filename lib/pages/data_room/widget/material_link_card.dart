import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

/// 자료의 주소를 보여주고 브라우저로 열어주는 카드.
class MaterialLinkCard extends StatelessWidget {
  final String url;

  const MaterialLinkCard({super.key, required this.url});

  /// 저장된 주소에는 'exam-archive.kr/...'처럼 스킴이 없을 수 있어,
  /// 없으면 https를 붙여 연다.
  Uri get _uri {
    final Uri parsed = Uri.parse(url);
    return parsed.hasScheme ? parsed : Uri.parse('https://$url');
  }

  Future<void> _open(BuildContext context) async {
    bool opened = false;
    try {
      opened = await launchUrl(_uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
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
