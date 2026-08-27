import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/provider/roadmap_chat_view_model.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/widget/chat_bubble.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/widget/chat_input_bar.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/widget/typing_bubble.dart';

class RoadmapChatPage extends ConsumerStatefulWidget {
  final String certificateName;

  /// 대화 내역 화면에서 열렸는지 여부. true면 앱바의 대화 내역 버튼이
  /// 화면을 새로 쌓지 않고 이미 스택 아래에 있는 대화 내역으로 돌아간다.
  final bool openedFromHistory;
  final int? historyId;
  final bool isRootChat;

  const RoadmapChatPage({
    super.key,
    required this.certificateName,
    this.openedFromHistory = false,
    this.historyId,
    this.isRootChat = false,
  });

  @override
  ConsumerState<RoadmapChatPage> createState() => _RoadmapChatPageState();
}

class _RoadmapChatPageState extends ConsumerState<RoadmapChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
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
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = roadmapChatViewModelProvider(
      RoadmapChatSession(
        certificateName: widget.certificateName,
        historyId: widget.historyId,
      ),
    );
    final RoadmapChatState state = ref.watch(provider);
    final RoadmapChatViewModel viewModel = ref.read(provider.notifier);

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
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
        itemCount: state.messages.length + (state.isBotTyping ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space1),
        itemBuilder: (context, index) {
          if (index == state.messages.length) return const TypingBubble();
          return ChatBubble(message: state.messages[index]);
        },
      ),
    );
  }
}
