import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/search_bar/custom_search_bar.dart';
import 'package:li_on/pages/roadmap/chat_history/provider/chat_history_view_model.dart';
import 'package:li_on/pages/roadmap/chat_history/widget/chat_history_card.dart';

/// 태블릿·웹처럼 폭이 넓은 화면에서 목록이 과하게 늘어나지 않도록 제한한다.
const double _maxContentWidth = 640;

class ChatHistoryPage extends ConsumerWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChatHistoryViewModel viewModel = ref.read(
      chatHistoryViewModelProvider.notifier,
    );
    final AsyncValue<List<ChatHistoryItem>> historiesAsync = ref.watch(
      filteredChatHistoriesProvider,
    );

    return BaseScaffold(
      appBar: const CustomAppBar(title: '대화 내역'),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space0),
              CustomSearchBar(hintText: '대화 검색', onChanged: viewModel.setQuery),
              const SizedBox(height: AppSpacing.space2),
              Expanded(
                child: historiesAsync.when(
                  data: (histories) => histories.isEmpty
                      ? Center(
                          child: Text(
                            '대화 내역이 없어요',
                            style: AppTextStyle.subText,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.space4,
                          ),
                          itemCount: histories.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.space1),
                          itemBuilder: (context, index) {
                            final ChatHistoryItem history = histories[index];
                            return ChatHistoryCard(
                              history: history,
                              onTap: () {
                                if (ModalRoute.of(context)?.isCurrent != true) {
                                  return;
                                }
                                // pushReplacement가 아니라 push로 쌓아야
                                // 대화에서 뒤로 나올 때 이 화면으로 돌아온다.
                                context.push(
                                  '/roadmap/chat/'
                                  '${Uri.encodeComponent(history.certificateName)}'
                                  '?from=history',
                                );
                              },
                            );
                          },
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      '대화 내역을 불러오지 못했어요',
                      style: AppTextStyle.subText,
                    ),
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
