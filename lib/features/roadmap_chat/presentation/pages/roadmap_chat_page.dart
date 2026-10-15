import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_chat_view_model.dart';
import 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_hint_provider.dart';
import 'package:li_on/features/roadmap_chat/presentation/widgets/chat_bubble.dart';
import 'package:li_on/features/roadmap_chat/presentation/widgets/chat_input_bar.dart';
import 'package:li_on/features/roadmap_chat/presentation/widgets/resource_recommendation_sheet.dart';
import 'package:li_on/features/roadmap_chat/presentation/widgets/roadmap_button_hint.dart';
import 'package:li_on/features/roadmap_chat/presentation/widgets/roadmap_steps_sheet.dart';
import 'package:li_on/features/roadmap_chat/presentation/widgets/typing_bubble.dart';

/// 대화 목록이 맨 아래에서 이 거리(px) 안이면 맨 아래를 보고 있다고 본다.
const double _bottomSlack = 40;

class RoadmapChatPage extends ConsumerStatefulWidget {
  final String certificateName;

  /// 대화 내역 화면에서 열렸는지 여부. true면 앱바의 대화 내역 버튼이
  /// 화면을 새로 쌓지 않고 이미 스택 아래에 있는 대화 내역으로 돌아간다.
  final bool openedFromHistory;
  final int? historyId;
  final bool isRootChat;

  /// 특정 자격증 상세에서 들어왔다면 그 자격증의 jmCd. 새 세션을 만들 때
  /// 함께 보내고, "추천 자료" 진입점을 보여줄지 판단하는 데 쓴다.
  final String? jmCd;

  const RoadmapChatPage({
    super.key,
    required this.certificateName,
    this.openedFromHistory = false,
    this.historyId,
    this.isRootChat = false,
    this.jmCd,
  });

  @override
  ConsumerState<RoadmapChatPage> createState() => _RoadmapChatPageState();
}

class _RoadmapChatPageState extends ConsumerState<RoadmapChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// 사용자가 대화의 맨 아래를 보고 있는지. 키보드가 올라와 목록이 줄어들어도
  /// 맨 아래를 보고 있었다면 그 자리를 따라가야 최신 메시지가 가려지지 않는다.
  bool _isAtBottom = true;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_scrollController.hasClients) return;
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      // 이동하는 동안 아래쪽 항목의 높이가 확정되면 끝이 더 멀어지므로 맞춘다.
      if (!_scrollController.hasClients) return;
      final ScrollPosition position = _scrollController.position;
      if (position.extentAfter > 0) {
        _scrollController.jumpTo(position.maxScrollExtent);
      }
    });
  }

  /// 스크롤 위치가 실제로 움직였을 때만 맨 아래 여부를 갱신한다. 키보드로
  /// 목록 높이만 줄어든 경우는 위치가 그대로라 직전 값이 유지된다.
  bool _trackBottom(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      _isAtBottom = notification.metrics.extentAfter < _bottomSlack;
    }
    return false;
  }

  /// 키보드 등으로 보이는 영역이 줄거나 항목 높이가 확정돼 끝 위치가 바뀌었을
  /// 때, 맨 아래를 보고 있었다면 새 끝으로 따라간다. 이동 중이면 그 이동이
  /// 끝에서 맞추므로 건드리지 않는다.
  bool _followBottom(ScrollMetricsNotification notification) {
    if (!_isAtBottom || notification.metrics.extentAfter <= 0) return false;
    if (_scrollController.position.isScrollingNotifier.value) return false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    return false;
  }

  /// 대화 내역에서 들어온 화면이면 그 화면으로 되돌아가고, 아니면 새로 연다.
  /// 대화 내역 → 대화 → 대화 내역이 계속 쌓이는 것을 막는다.
  void _openChatHistory(BuildContext context) {
    if (widget.openedFromHistory) {
      context.pop();
      return;
    }
    context.push('/roadmap/history');
  }

  void _handleSend(RoadmapChatViewModel viewModel) {
    final String text = _controller.text;
    if (text.trim().isEmpty) return;
    viewModel.sendMessage(text);
    _controller.clear();
    _isAtBottom = true;
    _scrollToBottom();
  }

  /// 이 자격증에 맞는 학습 자료를 추천받는 시트를 연다. jmCd·세션이 모두
  /// 있어야 부를 수 있어, 버튼 자체가 그 조건일 때만 보인다.
  void _openResourceRecommendations(
    BuildContext context,
    RoadmapChatState state,
  ) {
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => ResourceRecommendationSheet(
        jmCd: state.jmCd!,
        sessionId: state.sessionId!,
        certificateName: widget.certificateName,
      ),
    );
  }

  /// 이 대화의 로드맵을 확인하는 시트를 연다. 로드맵은 세션에 붙어 만들어지고
  /// 대화에서 자격증을 알아야 만들 수 있어, 대화가 없거나 자격증이 연결되지
  /// 않았다면 안내만 한다.
  void _openRoadmapSteps(BuildContext context, RoadmapChatState state) {
    ref.read(roadmapHintProvider.notifier).dismiss();
    final int? sessionId = state.sessionId;
    if (sessionId == null || state.jmCd == null) {
      CustomSnackbar.show(
        context,
        message: '자격증을 알아야 로드맵을 확인할 수 있어요.\n대화를 통해 자격증을 알려주세요.',
        type: SnackbarType.error,
      );
      return;
    }
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => RoadmapStepsSheet(sessionId: sessionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = roadmapChatViewModelProvider(
      RoadmapChatSession(
        certificateName: widget.certificateName,
        historyId: widget.historyId,
        jmCd: widget.jmCd,
      ),
    );
    final RoadmapChatState state = ref.watch(provider);
    final RoadmapChatViewModel viewModel = ref.read(provider.notifier);
    final bool canOpenRoadmap = state.sessionId != null && state.jmCd != null;
    final bool showHint = ref.watch(roadmapHintProvider);

    ref.listen(provider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return BaseScaffold(
      appBar: CustomAppBar(
        title: '${widget.certificateName} 로드맵',
        showBackButton: !widget.isRootChat,
        actions: [
          if (widget.historyId == null) ...[
            GestureDetector(
              onTap: state.isBotTyping
                  ? null
                  : () {
                      _controller.clear();
                      viewModel.startNewChat();
                    },
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.add_comment_outlined,
                size: 20,
                color: state.isBotTyping
                    ? AppColors.placeholder
                    : AppColors.text,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
          ],
          GestureDetector(
            onTap: () => _openRoadmapSteps(context, state),
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.route_outlined,
              size: 20,
              color: canOpenRoadmap ? AppColors.text : AppColors.placeholder,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          if (state.jmCd != null && state.sessionId != null) ...[
            GestureDetector(
              onTap: () => _openResourceRecommendations(context, state),
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 20,
                color: AppColors.text,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
          ],
          GestureDetector(
            onTap: () => _openChatHistory(context),
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.text,
            ),
          ),
        ],
      ),
      bottomBar: ChatInputBar(
        controller: _controller,
        enabled: !state.isBotTyping,
        onSend: () => _handleSend(viewModel),
      ),
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _trackBottom,
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: _followBottom,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space3,
                ),
                itemCount: state.messages.length + (state.isBotTyping ? 1 : 0),
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.space1),
                itemBuilder: (context, index) {
                  if (index == state.messages.length) {
                    return const TypingBubble();
                  }
                  return ChatBubble(message: state.messages[index]);
                },
              ),
            ),
          ),
          if (showHint)
            Positioned(
              top: 0,
              right: 0,
              left: AppSpacing.space6,
              child: RoadmapButtonHint(
                hasCertificate: state.jmCd != null,
                onDismiss: ref.read(roadmapHintProvider.notifier).dismiss,
              ),
            ),
        ],
      ),
    );
  }
}
