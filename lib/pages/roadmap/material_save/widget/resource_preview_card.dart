import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/material_type_badge.dart';
import 'package:li_on/pages/roadmap/material_save/model/material_resource.dart';

/// 자료방에 저장할 자료의 미리보기 카드. 제목·형태 배지·주소를 보여준다.
class ResourcePreviewCard extends StatelessWidget {
  final MaterialResource resource;

  /// 사용자가 입력 중인 제목. 제목 입력창과 미리보기가 따로 놀지 않도록
  /// 넘겨준다. null이면 [resource]의 추천 제목을 그대로 쓴다.
  final String? title;

  const ResourcePreviewCard({super.key, required this.resource, this.title});

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
                  title ?? resource.title,
                  style: AppTextStyle.mainText.copyWith(color: AppColors.text),
                ),
              ),
              const SizedBox(width: AppSpacing.space1),
              MaterialTypeBadge(type: resource.type),
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
