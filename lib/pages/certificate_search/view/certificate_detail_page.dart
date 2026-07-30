import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/card/custom_progress_bar.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/certificate_search/data/certificate_repository.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';
import 'package:li_on/pages/certificate_search/view_model/certificate_detail_view_model.dart';

class CertificateDetailPage extends ConsumerWidget {
  final String certificateId;

  /// 목록 화면에서 이미 알고 있는 자격증 이름. 상세 데이터가 로딩되는 동안
  /// AppBar 제목이 비어 보이지 않도록 임시로 사용한다.
  final String? initialTitle;

  const CertificateDetailPage({
    super.key,
    required this.certificateId,
    this.initialTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CertificateDetail?> detailAsync = ref.watch(
      certificateDetailProvider(certificateId),
    );

    return BaseScaffold(
      appBar: CustomAppBar(
        title: detailAsync.value?.name ?? initialTitle ?? '',
        actions: [_BookmarkButton(certificateId: certificateId)],
      ),
      bottomBar: CustomElevatedButton(
        text: '로드맵 만들기',
        backgroundColor: AppColors.primary,
        // 로드맵 기능이 아직 없어 연결할 동작이 없다. null을 넘기면
        // CustomElevatedButton이 자동으로 비활성 스타일을 적용한다.
        onPressed: null,
      ),
      child: detailAsync.when(
        data: (detail) => detail == null
            ? Center(
                child: Text('자격증 정보를 찾을 수 없어요', style: AppTextStyle.subText),
              )
            : _CertificateDetailBody(detail: detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('정보를 불러오지 못했어요', style: AppTextStyle.subText)),
      ),
    );
  }
}

/// 북마크 상태만 watch해서, 토글 시 상세 본문 전체가 다시 빌드되는 것을 막는다.
class _BookmarkButton extends ConsumerWidget {
  final String certificateId;

  const _BookmarkButton({required this.certificateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isBookmarked = ref.watch(
      certificateDetailViewModelProvider(
        certificateId,
      ).select((state) => state.isBookmarked),
    );

    return AppBarBookmarkButton(
      isBookmarked: isBookmarked,
      onTap: () => ref
          .read(certificateDetailViewModelProvider(certificateId).notifier)
          .toggleBookmark(),
    );
  }
}

class _CertificateDetailBody extends StatelessWidget {
  final CertificateDetail detail;

  const _CertificateDetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space3),
          _HeaderCard(detail: detail),
          const SizedBox(height: AppSpacing.space5),
          Text('시험 정보', style: AppTextStyle.section),
          const SizedBox(height: AppSpacing.space1),
          _InfoRow(label: '응시료', value: detail.examFee),
          _InfoRow(label: '합격률', value: '${detail.passRate.toStringAsFixed(1)}%'),
          _InfoRow(label: '시험 시간', value: detail.examDuration),
          _InfoRow(label: '과목 수', value: '${detail.subjectCount}과목'),
          const SizedBox(height: AppSpacing.space5),
          Text('시험 과목', style: AppTextStyle.section),
          const SizedBox(height: AppSpacing.space2),
          ...detail.subjects.map(
            (subject) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: _SubjectCard(subject: subject),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final CertificateDetail detail;

  const _HeaderCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(AppSpacing.space3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.name,
            style: AppTextStyle.baseTextStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.space0),
          Text(detail.issuingOrg, style: AppTextStyle.mainText),
          const SizedBox(height: AppSpacing.space1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              detail.level,
              style: AppTextStyle.baseTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.mainText),
          Text(
            value,
            style: AppTextStyle.baseTextStyle.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final ExamSubject subject;

  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSpacing.space2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject.name,
                style: AppTextStyle.baseTextStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(subject.percent * 100).round()}%',
                style: AppTextStyle.mainText,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          CustomProgressBar(
            percent: subject.percent,
            showLabel: false,
            height: 6,
          ),
        ],
      ),
    );
  }
}
