import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

/// 앱바의 로드맵 버튼을 가리키는 말풍선. 처음 들어왔을 때 무슨 버튼인지
/// 알려준다.
class RoadmapButtonHint extends StatelessWidget {
  const RoadmapButtonHint({
    super.key,
    required this.hasCertificate,
    required this.onDismiss,
  });

  /// 대화에 자격증이 연결돼 있는지. 없으면 로드맵 버튼이 꺼져 있으니, 자격증
  /// 이름을 말해야 한다는 조건을 함께 알려준다.
  final bool hasCertificate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final String message = hasCertificate
        ? '여기서 대화로 만든 로드맵을 확인할 수 있어요'
        : '자격증 이름을 말하면 여기서 로드맵을 만들 수 있어요';
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.space6),
            child: Icon(
              Icons.arrow_drop_up,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space2,
              vertical: AppSpacing.space1,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.space1,
              children: [
                Flexible(
                  child: Text(
                    message,
                    style: AppTextStyle.subText.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                const Icon(Icons.close, size: 14, color: AppColors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
