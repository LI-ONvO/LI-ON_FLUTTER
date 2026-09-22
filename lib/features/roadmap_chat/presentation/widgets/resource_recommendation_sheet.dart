import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/features/data_room/data/data_room_repository.dart';
import 'package:li_on/features/data_room/data/resource_recommendation.dart';
import 'package:li_on/features/data_room/presentation/view_models/data_room_view_model.dart';

/// 로드맵 대화의 "추천 자료" 버튼으로 여는 시트.
/// 현재 자격증·세션에 맞는 학습 자료를 AI가 추천해 주고, 항목별로 바로
/// 자료방에 저장할 수 있다.
class ResourceRecommendationSheet extends ConsumerStatefulWidget {
  const ResourceRecommendationSheet({
    super.key,
    required this.jmCd,
    required this.sessionId,
    required this.certificateName,
  });

  final String jmCd;
  final int sessionId;
  final String certificateName;

  @override
  ConsumerState<ResourceRecommendationSheet> createState() =>
      _ResourceRecommendationSheetState();
}

class _ResourceRecommendationSheetState
    extends ConsumerState<ResourceRecommendationSheet> {
  late final Future<ResourceRecommendationResult> _future = ref
      .read(dataRoomRepositoryProvider)
      .fetchRecommendations(jmCd: widget.jmCd, sessionId: widget.sessionId);

  final Set<int> _savedIndices = {};
  int? _savingIndex;

  Future<void> _save(int index, ResourceRecommendationItem item) async {
    setState(() => _savingIndex = index);
    try {
      await ref
          .read(dataRoomMaterialsProvider.notifier)
          .add(
            title: item.title,
            category: widget.certificateName,
            source: '로드맵 추천 자료',
            type: MaterialResourceType.link,
            url: item.url,
            sessionId: widget.sessionId,
            jmCd: widget.jmCd,
          );
      if (!mounted) return;
      setState(() {
        _savedIndices.add(index);
        _savingIndex = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingIndex = null);
      CustomSnackbar.show(
        context,
        message: '저장하지 못했어요',
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 14),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Text('추천 자료', style: AppTextStyle.section),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(Icons.close, color: AppColors.text),
                  ),
                ],
              ),
              Flexible(
                child: FutureBuilder<ResourceRecommendationResult>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.space6,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.space6,
                        ),
                        child: Center(
                          child: Text(
                            '추천 자료를 불러오지 못했어요',
                            style: AppTextStyle.subText,
                          ),
                        ),
                      );
                    }
                    final List<ResourceRecommendationItem> items =
                        snapshot.data!.items;
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.space6,
                        ),
                        child: Center(
                          child: Text('추천할 자료가 없어요', style: AppTextStyle.subText),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space3,
                      ),
                      child: Column(
                        spacing: AppSpacing.space2,
                        children: [
                          for (int i = 0; i < items.length; i++)
                            _RecommendationTile(
                              item: items[i],
                              saved: _savedIndices.contains(i),
                              saving: _savingIndex == i,
                              onSave: () => _save(i, items[i]),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({
    required this.item,
    required this.saved,
    required this.saving,
    required this.onSave,
  });

  final ResourceRecommendationItem item;
  final bool saved;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: AppTextStyle.card),
          const SizedBox(height: AppSpacing.space1),
          Text(item.reason, style: AppTextStyle.subText),
          const SizedBox(height: AppSpacing.space2),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: saved || saving ? null : onSave,
              child: Text(
                saved ? '저장됨' : (saving ? '저장 중…' : '자료방에 저장'),
                style: AppTextStyle.mainText.copyWith(
                  color: saved ? AppColors.placeholder : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
