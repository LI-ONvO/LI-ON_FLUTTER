import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/roadmap/material_save/model/material_resource.dart';

/// 자료방에 저장할 자료의 미리보기 카드. 제목·형태 배지·주소를 보여준다.
class ResourcePreviewCard extends StatelessWidget {
  final MaterialResource resource;

  const ResourcePreviewCard({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목이 길어지면 배지를 밀어내지 않고 여러 줄로 감긴다.
              Expanded(
                child: Text(
                  resource.title,
                  style: AppTextStyle.mainText.copyWith(color: AppColors.text),
                ),
              ),
              const SizedBox(width: AppSpacing.space1),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.space0),
                ),
                child: Text(
                  resource.type.label,
                  style: AppTextStyle.subText.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
          if (resource.hasUrl) ...[
            const SizedBox(height: 6),
            Text(
              resource.url,
              style: AppTextStyle.subText.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
