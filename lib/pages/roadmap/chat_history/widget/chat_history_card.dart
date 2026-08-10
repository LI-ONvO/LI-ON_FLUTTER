import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/roadmap/chat_history/model/chat_history_item.dart';
import 'package:li_on/pages/roadmap/chat_history/widget/chat_history_tag.dart';

/// 대화 내역 목록의 카드 한 장.
/// 자격증 배지·날짜 / 요약 제목 / 메시지 수·계획 포함 배지 3단으로 구성된다.
class ChatHistoryCard extends StatelessWidget {
  final ChatHistoryItem history;
  final VoidCallback? onTap;

  const ChatHistoryCard({super.key, required this.history, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.space2),
          border: Border.all(color: AppColors.background),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // 자격증 이름이 길어지면 배지가 날짜를 밀어내지 않고 줄어든다.
                Flexible(
                  child: ChatHistoryTag.certificate(
                    label: history.certificateName,
                  ),
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(
                  history.updatedAtLabel,
                  style: AppTextStyle.subText.copyWith(
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space1),
            // 제목은 화면 폭에 맞춰 자연스럽게 여러 줄로 감긴다.
            Text(history.title, style: AppTextStyle.card),
            const SizedBox(height: AppSpacing.space1),
            // 좁은 화면에서 메시지 수와 배지가 겹치지 않도록 줄바꿈을 허용한다.
            Wrap(
              spacing: AppSpacing.space1,
              runSpacing: AppSpacing.space0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  history.messageCountLabel,
                  style: AppTextStyle.subText.copyWith(
                    color: AppColors.placeholder,
                  ),
                ),
                if (history.hasPlan) const ChatHistoryTag.plan(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
