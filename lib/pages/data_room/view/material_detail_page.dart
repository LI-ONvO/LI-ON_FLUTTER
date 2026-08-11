import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/data_room/provider/data_room_view_model.dart';
import 'package:li_on/pages/data_room/view/material_actions.dart';
import 'package:li_on/pages/data_room/widget/material_link_card.dart';
import 'package:li_on/pages/data_room/widget/material_more_button.dart';

/// 태블릿·웹처럼 폭이 넓은 화면에서 본문이 과하게 늘어나지 않도록 제한한다.
const double _maxContentWidth = 640;

/// 메모 본문의 줄 간격(20px)을 글자 크기(14px) 기준 배수로 환산한 값.
const double _memoLineHeight = 20 / 14;

/// 자료방에서 고른 자료 한 건의 상세 화면.
class MaterialDetailPage extends ConsumerWidget {
  final String materialId;

  const MaterialDetailPage({super.key, required this.materialId});

  Widget _body(SavedMaterial material) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space1),
          Text(material.title, style: AppTextStyle.semiBold),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MaterialTag(
                text: material.category,
                background: AppColors.light,
                foreground: AppColors.primary,
              ),
              _MaterialTag(
                text: material.type.label,
                background: AppColors.background,
                foreground: AppColors.subText,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${material.savedAtDateLabel} 저장',
            style: AppTextStyle.subText.copyWith(
              fontSize: 13,
              color: AppColors.placeholder,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          const Divider(height: 1, thickness: 1, color: AppColors.background),
          const SizedBox(height: AppSpacing.space4),
          if (material.hasUrl) ...[
            MaterialLinkCard(url: material.url),
            const SizedBox(height: AppSpacing.space5),
          ],
          Text(
            '메모',
            style: AppTextStyle.baseTextStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            material.memo.isEmpty ? '작성한 메모가 없어요' : material.memo,
            style: AppTextStyle.mainText.copyWith(height: _memoLineHeight),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SavedMaterial? material = ref.watch(materialByIdProvider(materialId));

    return BaseScaffold(
      appBar: CustomAppBar(
        title: '자료 상세',
        actions: [
          if (material != null)
            MaterialMoreButton(
              onEdit: () => openMaterialEditSheet(context, material),
              onDelete: () async {
                final bool deleted = await confirmDeleteMaterial(
                  context,
                  ref,
                  material,
                );
                // 지운 자료의 상세 화면에 남아 있을 이유가 없으므로 목록으로
                // 돌아간다.
                if (deleted && context.mounted) Navigator.of(context).pop();
              },
            ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          // 스크롤 영역은 내용 높이만큼만 차지하려 하므로, 내용이 짧아도
          // 화면 가운데로 내려가지 않게 높이를 꽉 채운다.
          child: SizedBox(
            height: double.infinity,
            child: material == null
                ? Center(
                    child: Text('자료를 찾을 수 없어요', style: AppTextStyle.subText),
                  )
                : _body(material),
          ),
        ),
      ),
    );
  }
}

/// 상세 화면 제목 아래에 붙는 카테고리·형태 배지.
class _MaterialTag extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _MaterialTag({
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.space0),
      ),
      child: Text(
        text,
        style: AppTextStyle.subText.copyWith(color: foreground),
      ),
    );
  }
}
