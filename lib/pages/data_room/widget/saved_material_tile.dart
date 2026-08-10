import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/material_type_badge.dart';
import 'package:li_on/pages/data_room/model/saved_material.dart';
import 'package:li_on/pages/data_room/widget/material_more_button.dart';

/// 자료방 목록의 한 줄. 제목·형태 배지 / 출처 / 저장 날짜로 구성된다.
class SavedMaterialTile extends StatelessWidget {
  final SavedMaterial material;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SavedMaterialTile({
    super.key,
    required this.material,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(top: AppSpacing.space3, bottom: 17),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.background)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 제목이 길어지면 배지를 밀어내지 않고 말줄임한다.
                      Flexible(
                        child: Text(
                          material.title,
                          style: AppTextStyle.card,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space1),
                      MaterialTypeBadge(type: material.type),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space0),
                  Text(
                    material.source,
                    style: AppTextStyle.subText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            // 날짜는 제목과 같은 줄에 맞춰 살짝 내린다.
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                material.savedAtLabel,
                style: AppTextStyle.subText.copyWith(
                  color: AppColors.placeholder,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space1),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: MaterialMoreButton(
                iconSize: 18,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
