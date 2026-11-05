import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/features/chat/data/chat_message.dart';
import 'package:li_on/features/data_room/presentation/widgets/material_link_card.dart';
import 'package:url_launcher/url_launcher.dart';

const double bubbleMaxWidth = 260;

BoxDecoration chatBubbleDecoration({required bool isUser}) {
  return BoxDecoration(
    color: isUser ? AppColors.primary : AppColors.background,
    borderRadius: BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 16),
    ),
  );
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.sender == ChatSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: bubbleMaxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space2,
          ),
          decoration: chatBubbleDecoration(isUser: isUser),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUser)
                Text(
                  message.text,
                  style: AppTextStyle.mainText.copyWith(color: AppColors.white),
                )
              else
                _BotMessageBody(text: message.text),
              const SizedBox(height: AppSpacing.space0),
              Text(
                message.timestamp.toKoreanTimeLabel,
                style: AppTextStyle.subText.copyWith(
                  fontSize: 10,
                  color: isUser
                      ? const Color(0xFFDBEAFE)
                      : AppColors.placeholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 봇 답변은 마크다운으로 오므로 서식을 입혀 보여준다.
class _BotMessageBody extends StatelessWidget {
  final String text;

  const _BotMessageBody({required this.text});

  Future<void> _openLink(BuildContext context, String? href) async {
    final Uri? uri = href == null ? null : resolveMaterialUrl(href);
    bool opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (opened || !context.mounted) return;
    CustomSnackbar.show(
      context,
      message: '링크를 열지 못했어요',
      type: SnackbarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle body = AppTextStyle.mainText.copyWith(
      color: AppColors.text,
    );
    final TextStyle strong = body.copyWith(fontWeight: FontWeight.w700);

    return MarkdownBody(
      data: text,
      // 답변의 한 줄 바꿈을 공백으로 합치지 않고 그대로 둔다.
      softLineBreak: true,
      onTapLink: (_, href, _) => _openLink(context, href),
      // 답변에 섞인 외부 이미지를 내려받지 않도록 대체 글만 보여준다.
      imageBuilder: (_, _, alt) => Text(alt ?? '', style: body),
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: body,
        strong: strong,
        h1: strong.copyWith(fontSize: 16),
        h2: strong.copyWith(fontSize: 15),
        h3: strong,
        h4: strong,
        h5: strong,
        h6: strong,
        listBullet: body,
        tableHead: strong,
        tableBody: body,
        a: body.copyWith(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
        blockSpacing: AppSpacing.space1,
        listIndent: AppSpacing.space4,
      ),
    );
  }
}
