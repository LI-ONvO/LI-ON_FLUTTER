import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/bottom_bar/custom_bottom_nav_bar.dart';
import 'package:li_on/core/widgets/card/custom_card.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/search_bar/custom_search_bar.dart';
import 'package:li_on/pages/certificate_search/provider/certificate_search_view_model.dart';
import 'package:li_on/pages/certificate_search/view/certificate_detail_page.dart';
import 'package:li_on/pages/roadmap_chat/view/roadmap_chat_page.dart';

class CertificateSearchPage extends ConsumerWidget {
  final String userName;

  const CertificateSearchPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CertificateSearchState state = ref.watch(
      certificateSearchViewModelProvider,
    );
    final CertificateSearchViewModel viewModel = ref.read(
      certificateSearchViewModelProvider.notifier,
    );
    final AsyncValue<List<Certificate>> certificatesAsync = ref.watch(
      filteredCertificatesProvider,
    );

    return BaseScaffold(
      appBar: null,
      bottomBar: CustomBottomNavBar(
        onTap: (index) {
          if (index != roadmapNavIndex) return;
          if (ModalRoute.of(context)?.isCurrent != true) return;
          Navigator.of(context).push(
            CupertinoPageRoute(
              // 학습 중인 자격증을 선택하는 기능이 아직 없어 임시로 고정값을 전달한다.
              builder: (context) =>
                  const RoadmapChatPage(certificateName: '정보처리기사'),
            ),
          );
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space4),
          Text(
            '안녕하세요, $userName님',
            style: AppTextStyle.baseTextStyle.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          CustomSearchBar(onChanged: viewModel.setQuery),
          const SizedBox(height: AppSpacing.space2),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: certificateCategories.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.space0),
              itemBuilder: (context, index) {
                final category = certificateCategories[index];
                return CustomBadge(
                  field: category,
                  selected: state.selectedCategory == category,
                  filled: true,
                  onTap: () => viewModel.selectCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Expanded(
            child: certificatesAsync.when(
              data: (certificates) => certificates.isEmpty
                  ? Center(
                      child: Text('검색 결과가 없어요', style: AppTextStyle.subText),
                    )
                  : ListView.separated(
                      itemCount: certificates.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.space2),
                      itemBuilder: (context, index) {
                        final certificate = certificates[index];
                        return CustomCard(
                          initial: certificate.initial,
                          title: certificate.name,
                          subtitle: certificate.category,
                          avatarBackgroundColor: certificate.accentColor
                              .withValues(alpha: 0.1),
                          avatarTextColor: certificate.accentColor,
                          trailing: const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: AppColors.placeholder,
                          ),
                          onTap: () {
                            if (ModalRoute.of(context)?.isCurrent != true) {
                              return;
                            }
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => CertificateDetailPage(
                                  certificateId: certificate.id,
                                  initialTitle: certificate.name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('목록을 불러오지 못했어요', style: AppTextStyle.subText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
