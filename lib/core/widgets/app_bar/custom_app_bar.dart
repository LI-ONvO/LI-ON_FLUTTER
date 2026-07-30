import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget> actions;

  const CustomAppBar({
    super.key,
    required this.title,
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                title,
                style: AppTextStyle.section,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  if (showBackButton)
                    _AppBarIconButton(
                      icon: Icons.arrow_back_ios_new,
                      size: 22,
                      onTap:
                          onBackPressed ??
                          () => Navigator.of(context).maybePop(),
                    ),
                  const Spacer(),
                  ...actions,
                ],
              ),
            ],
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
