import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/data_room/provider/data_room_view_model.dart';
import 'package:li_on/pages/data_room/view/material_actions.dart';
import 'package:li_on/pages/data_room/widget/saved_material_tile.dart';

/// 태블릿·웹처럼 폭이 넓은 화면에서 목록이 과하게 늘어나지 않도록 제한한다.
const double _maxContentWidth = 640;

/// 자료방 첫 화면. 로드맵 대화에서 저장한 자료를 카테고리별로 모아 보여준다.
class DataRoomPage extends ConsumerWidget {
  const DataRoomPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> categories = ref.watch(dataRoomCategoriesProvider);
    final String selectedCategory = ref.watch(selectedDataRoomCategoryProvider);
    final AsyncValue<List<SavedMaterial>> materialsAsync = ref.watch(
      filteredDataRoomMaterialsProvider,
    );

    return BaseScaffold(
      appBar: null,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space4),
              Text('자료방', style: AppTextStyle.semiBold.copyWith(fontSize: 18)),
              const SizedBox(height: 14),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.space1),
                  itemBuilder: (context, index) {
                    final String category = categories[index];
                    return CustomBadge(
                      field: category,
                      filled: true,
                      selected: selectedCategory == category,
                      onTap: () => ref
                          .read(dataRoomFilterProvider.notifier)
                          .select(category),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.space0),
              Expanded(
                child: materialsAsync.when(
                  data: (materials) => materials.isEmpty
                      ? Center(
                          child: Text(
                            '저장한 자료가 없어요',
                            style: AppTextStyle.subText,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.space4,
                          ),
                          itemCount: materials.length,
                          itemBuilder: (context, index) {
                            final SavedMaterial material = materials[index];
                            return SavedMaterialTile(
                              material: material,
                              onTap: () =>
                                  context.push('/materials/${material.id}'),
                              onEdit: () =>
                                  openMaterialEditSheet(context, material),
                              onDelete: () =>
                                  confirmDeleteMaterial(context, ref, material),
                            );
                          },
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text('자료를 불러오지 못했어요', style: AppTextStyle.subText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
