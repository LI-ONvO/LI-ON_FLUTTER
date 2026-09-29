import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_recommendation_view_model.dart';
import 'package:li_on/features/onboarding/presentation/pages/onboarding_page.dart';

/// 탐색·내 정보 화면에서 함께 쓰는 "맞춤 추천 자격증" 섹션.
/// 추천이 아직 없으면 만들기 카드를, 추천할 자격증이 없으면(서버가
/// 빈 목록이나 `NO_CANDIDATE_CERTIFICATE`를 주면) 안내 문구와 무작위
/// 자격증 한 건을, 그 밖의 실패는 다시 시도 문구를 보여준다.
class RecommendationSection extends ConsumerWidget {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CertificateRecommendationResult?> recommendationAsync =
        ref.watch(certificateRecommendationsProvider);

    return recommendationAsync.when(
      data: (result) {
        if (result == null) {
          return _GenerateCard(
            onTap: () => ref
                .read(certificateRecommendationsProvider.notifier)
                .generate(),
          );
        }
        if (result.items.isEmpty) {
          return const _NoRecommendationFallback(
            reason: _NoRecommendationReason.noCandidate,
          );
        }
        return SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: result.items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.space2),
            itemBuilder: (context, index) =>
                _RecommendationCard(item: result.items[index]),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 128,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        if (error is ApiException) {
          if (error.code == 'NO_CANDIDATE_CERTIFICATE') {
            return const _NoRecommendationFallback(
              reason: _NoRecommendationReason.noCandidate,
            );
          }
          if (error.code == 'ONBOARDING_NOT_COMPLETED') {
            return const _NoRecommendationFallback(
              reason: _NoRecommendationReason.onboardingIncomplete,
            );
          }
        }
        return GestureDetector(
          onTap: () => ref.invalidate(certificateRecommendationsProvider),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
            child: Text('추천을 불러오지 못했어요 · 다시 시도', style: AppTextStyle.subText),
          ),
        );
      },
    );
  }
}

/// 추천을 보여줄 수 없는 이유. 문구·액션 버튼이 이유에 따라 달라진다.
enum _NoRecommendationReason {
  /// 온보딩은 마쳤지만 서버가 매칭되는 자격증을 못 찾음(422).
  noCandidate,

  /// 아직 온보딩을 마치지 않아 추천 자체를 만들 수 없음(409).
  onboardingIncomplete,
}

/// 추천을 보여줄 수 없을 때: 안내 문구 + 무작위로 고른 자격증 한 건.
/// 온보딩을 아직 안 한 경우엔 "다시 시도" 대신 온보딩으로 바로 이동하는
/// 버튼을 준다 — 실패한 요청을 그냥 재시도해 봐야 다시 같은 이유로
/// 실패할 뿐이라, 실제로 할 수 있는 행동을 제안하는 게 낫다.
class _NoRecommendationFallback extends ConsumerWidget {
  const _NoRecommendationFallback({required this.reason});

  final _NoRecommendationReason reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Certificate? randomCertificate = ref.watch(randomCertificateProvider);
    final bool onboardingIncomplete =
        reason == _NoRecommendationReason.onboardingIncomplete;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                onboardingIncomplete
                    ? '온보딩을 완료하면 더 정확히 추천해드려요'
                    : '추천드릴 자격증이 없습니다',
                style: AppTextStyle.subText,
              ),
            ),
            GestureDetector(
              onTap: onboardingIncomplete
                  ? () => pushOnboardingForEdit(context, ref)
                  // 다시 GET 하면 저장된 빈 추천이 그대로 오니, 새로 만든다.
                  : () => ref
                        .read(certificateRecommendationsProvider.notifier)
                        .generate(),
              behavior: HitTestBehavior.opaque,
              child: Text(
                onboardingIncomplete ? '온보딩 하러 가기' : '다시 시도',
                style: AppTextStyle.subText.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        if (randomCertificate != null) ...[
          const SizedBox(height: AppSpacing.space2),
          _RandomCertificateCard(certificate: randomCertificate),
        ],
      ],
    );
  }
}

class _RandomCertificateCard extends StatelessWidget {
  const _RandomCertificateCard({required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (ModalRoute.of(context)?.isCurrent != true) return;
        context.push(
          '/search/certificate/${certificate.id}',
          extra: certificate.name,
        );
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
              certificate.category,
              style: AppTextStyle.subText.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              certificate.name,
              style: AppTextStyle.card,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.space1),
            Text('무작위로 골라본 자격증이에요', style: AppTextStyle.subText),
          ],
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
