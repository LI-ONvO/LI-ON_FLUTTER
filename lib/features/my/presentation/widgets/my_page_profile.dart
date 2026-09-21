import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class MyPageProfile extends StatelessWidget {
  final String nickname; // 회원가입시
  final String explanation; // 온보딩에서 고른 주제
  final VoidCallback? onEditTap;

  const MyPageProfile({
    super.key,
    required this.nickname,
    required this.explanation,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.heading),
      ),
      child: Row(
        children: [
          Icon(Icons.circle),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nickname, style: AppTextStyle.section),
                const SizedBox(height: AppSpacing.space0),
                Text(explanation),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          GestureDetector(onTap: onEditTap, child: Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }
}
