import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

/// 대화 내역 카드에 붙는 작은 배지.
/// 자격증 이름(파랑)과 '계획 포함'(초록) 두 가지로 쓰인다.
class ChatHistoryTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const ChatHistoryTag({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  const ChatHistoryTag.certificate({super.key, required this.label})
    : backgroundColor = AppColors.light,
      textColor = AppColors.primary;

  const ChatHistoryTag.plan({super.key, this.label = '계획 포함'})
    : backgroundColor = AppColors.successLight,
      textColor = AppColors.success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space1,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.space0),
      ),
      child: Text(
        label,
        style: AppTextStyle.subText.copyWith(color: textColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
