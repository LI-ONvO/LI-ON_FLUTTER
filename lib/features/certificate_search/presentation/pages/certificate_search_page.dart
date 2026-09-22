import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/badge/custom_badge.dart';
import 'package:li_on/core/widgets/card/custom_card.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/search_bar/custom_search_bar.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_search_view_model.dart';

class CertificateSearchPage extends ConsumerWidget {
  const CertificateSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 검색어가 바뀔 때마다 화면 전체가 다시 그려지지 않도록, 상태를 쓰는
    // 부분(카테고리 칩·결과 목록)만 아래에서 Consumer로 지켜본다.
    final CertificateSearchViewModel viewModel = ref.read(
      certificateSearchViewModelProvider.notifier,
    );
    final String userName =
        ref.watch(authSessionProvider).user?.nickname ?? '사용자';

    return BaseScaffold(
      appBar: null,
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
            child: Consumer(
              builder: (context, ref, child) {
                final String selectedCategory = ref.watch(
                  certificateSearchViewModelProvider.select(
                    (state) => state.selectedCategory,
                  ),
                );
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: certificateCategories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.space0),
                  itemBuilder: (context, index) {
                    final category = certificateCategories[index];
                    return CustomBadge(
                      field: category,
                      selected: selectedCategory == category,
                      filled: true,
                      onTap: () => viewModel.selectCategory(category),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final AsyncValue<List<Certificate>> certificatesAsync = ref
                    .watch(filteredCertificatesProvider);
                return certificatesAsync.when(
                  data: (certificates) => certificates.isEmpty
                      ? Center(
                          child: Text(
                            '검색 결과가 없어요',
                            style: AppTextStyle.subText,
                          ),
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
                                context.push(
                                  '/search/certificate/${certificate.id}',
                                  extra: certificate.name,
                                );
                              },
                            );
                          },
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => _SearchRetryError(
                    onRetry: () => ref.invalidate(certificatesProvider),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRetryError extends StatelessWidget {
  const _SearchRetryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('목록을 불러오지 못했어요', style: AppTextStyle.subText),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
