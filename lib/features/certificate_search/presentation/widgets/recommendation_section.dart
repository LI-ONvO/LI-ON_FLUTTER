import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_recommendation_view_model.dart';

/// 탐색 화면 상단의 "맞춤 추천 자격증" 가로 스크롤 섹션.
/// 추천이 아직 없으면 만들기 카드를, 실패하면 다시 시도 문구를 보여준다.
class RecommendationSection extends ConsumerWidget {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CertificateRecommendationResult?> recommendationAsync =
        ref.watch(certificateRecommendationsProvider);

    return recommendationAsync.when(
      data: (result) {
        final List<CertificateRecommendationItem> items =
            result?.items ?? const [];
        if (items.isEmpty) {
          return _GenerateCard(
            onTap: () => ref
                .read(certificateRecommendationsProvider.notifier)
                .generate(),
          );
        }
        return SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.space2),
            itemBuilder: (context, index) =>
                _RecommendationCard(item: items[index]),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 128,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => GestureDetector(
        onTap: () => ref.invalidate(certificateRecommendationsProvider),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
          child: Text('추천을 불러오지 못했어요 · 다시 시도', style: AppTextStyle.subText),
        ),
      ),
    );
  }
}

class _GenerateCard extends StatelessWidget {
  const _GenerateCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.space2),
            Expanded(
              child: Text('나에게 맞는 자격증을 추천받아보세요', style: AppTextStyle.mainText),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.item});

  final CertificateRecommendationItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (ModalRoute.of(context)?.isCurrent != true) return;
        context.push('/search/certificate/${item.jmCd}', extra: item.name);
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.background),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.category,
              style: AppTextStyle.subText.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              item.name,
              style: AppTextStyle.card,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              item.reason,
              style: AppTextStyle.subText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
