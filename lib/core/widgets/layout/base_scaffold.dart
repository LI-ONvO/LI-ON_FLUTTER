import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';

class BaseScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final Color? backGroudColor;

  /// 키보드가 올라올 때 본문 높이를 줄일지 여부. 검색창처럼 입력창이
  /// 화면 위쪽에 고정돼 있어 굳이 줄일 필요가 없는 화면은 false로 주면,
  /// 아래쪽 고정 크기 요소들이 줄어든 높이에 맞지 않아 오버플로우가
  /// 나는 것을 막을 수 있다.
  final bool resizeToAvoidBottomInset;

  const BaseScaffold({
    super.key,
    required this.appBar,
    required this.child,
    this.bottomBar,
    this.floatingActionButton,
    this.backGroudColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
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
