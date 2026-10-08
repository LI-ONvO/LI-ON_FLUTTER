import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';

class BaseScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final Color? backGroudColor;

  const BaseScaffold({
    super.key,
    required this.appBar,
    required this.child,
    this.bottomBar,
    this.floatingActionButton,
    this.backGroudColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      // bottomNavigationBar는 키보드가 올라와도 밀려 올라가지 않아 하단 버튼이
      // 키보드에 가려진다. 본문 Column 아래에 두면 줄어든 body와 함께 키보드
      // 위로 올라온다.
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: child,
              ),
            ),
            if (bottomBar != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: bottomBar,
              ),
          ],
        ),
      ),
    );
  }
}
