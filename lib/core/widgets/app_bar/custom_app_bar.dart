import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  /// 제목 바로 오른쪽에 붙는 위젯.
  final Widget? titleTrailing;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget> actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.titleTrailing,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox.fromSize(
        size: preferredSize,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          // 제목은 가운데에 두되, 공간이 모자라면 좌우 버튼을 피해 밀리고 줄어든다.
          child: NavigationToolbar(
            middleSpacing: AppSpacing.space1,
            leading: showBackButton
                ? _AppBarIconButton(
                    icon: Icons.arrow_back_ios_new,
                    size: 22,
                    onTap:
                        onBackPressed ??
                        () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/search');
                          }
                        },
                  )
                : null,
            middle: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.space1,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyle.section,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?titleTrailing,
              ],
            ),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: actions),
          ),
        ),
      ),
    );
  }
}

class AppBarBookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback? onTap;

  const AppBarBookmarkButton({
    super.key,
    this.isBookmarked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _AppBarIconButton(
      icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
      size: 20,
      onTap: onTap,
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: size, color: AppColors.text),
    );
  }
}
