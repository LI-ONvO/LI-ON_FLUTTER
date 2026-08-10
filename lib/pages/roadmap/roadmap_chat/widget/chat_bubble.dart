import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/model/chat_message.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/widget/quick_actions.dart';

const double bubbleMaxWidth = 260;

BoxDecoration chatBubbleDecoration({required bool isUser}) {
  return BoxDecoration(
    color: isUser ? AppColors.primary : AppColors.background,
    borderRadius: BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 16),
    ),
  );
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<ChatQuickAction> onQuickAction;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.sender == ChatSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: bubbleMaxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space2,
          ),
          decoration: chatBubbleDecoration(isUser: isUser),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: AppTextStyle.mainText.copyWith(
                  color: isUser ? AppColors.white : AppColors.text,
                ),
              ),
              if (message.actions.isNotEmpty)
                QuickActions(actions: message.actions, onTap: onQuickAction),
              const SizedBox(height: AppSpacing.space0),
              Text(
                message.timestamp.toKoreanTimeLabel,
                style: AppTextStyle.subText.copyWith(
                  fontSize: 10,
                  color: isUser
                      ? const Color(0xFFDBEAFE)
                      : AppColors.placeholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
