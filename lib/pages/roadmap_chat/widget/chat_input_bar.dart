import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.only(top: AppSpacing.space2),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              hintText: '메시지를 입력하세요',
              controller: controller,
              enabled: enabled,
              fillColor: AppColors.background,
              borderRadius: 20,
              showBorder: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space2,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: AppSpacing.space1),
          GestureDetector(
            onTap: enabled ? onSend : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: enabled ? AppColors.primary : AppColors.placeholder,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 16,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
