import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/roadmap_chat/provider/roadmap_chat_view_model.dart';
import 'package:li_on/pages/roadmap_chat/widget/chat_bubble.dart';
import 'package:li_on/pages/roadmap_chat/widget/chat_input_bar.dart';
import 'package:li_on/pages/roadmap_chat/widget/typing_bubble.dart';

class RoadmapChatPage extends ConsumerStatefulWidget {
  final String certificateName;

  const RoadmapChatPage({super.key, required this.certificateName});

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

  void _handleSend(RoadmapChatViewModel viewModel) {
    final String text = _controller.text;
    if (text.trim().isEmpty) return;
    viewModel.sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = roadmapChatViewModelProvider(widget.certificateName);
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
        actions: const [
          Icon(Icons.more_horiz, size: 20, color: AppColors.text),
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
          return ChatBubble(
            message: state.messages[index],
            onQuickAction: viewModel.handleQuickAction,
          );
        },
      ),
    );
  }
}
