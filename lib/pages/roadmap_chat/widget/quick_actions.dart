import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/roadmap_chat/model/chat_message.dart';

class QuickActions extends StatelessWidget {
  final List<ChatQuickAction> actions;
  final ValueChanged<ChatQuickAction> onTap;

  const QuickActions({super.key, required this.actions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space2),
              child: GestureDetector(
                onTap: () => onTap(action),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  action.label,
                  style: AppTextStyle.button.copyWith(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
