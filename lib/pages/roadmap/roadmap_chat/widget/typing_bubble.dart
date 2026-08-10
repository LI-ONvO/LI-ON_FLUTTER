import 'package:flutter/material.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/widget/chat_bubble.dart';

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        decoration: chatBubbleDecoration(isUser: false),
        child: Text('입력 중...', style: AppTextStyle.subText),
      ),
    );
  }
}
