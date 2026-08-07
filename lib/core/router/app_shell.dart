import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/widgets/bottom_bar/custom_bottom_nav_bar.dart';

/// 하단 탭 5개가 공유하는 셸. 실제로 선택된 탭과 화면은 [navigationShell]이
/// 라우터 상태로부터 결정하므로, 탭 하이라이트와 실제 이동이 항상 일치한다.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // Scaffold는 extendBody가 false(기본값)일 때 body에 넘기는
      // MediaQuery의 bottom padding을 초기화하지 않는다 (body가
      // bottomNavigationBar 뒤로 확장되는 경우에만 초기화됨). 탭 화면들은
      // 이미 이 Scaffold가 bottomNavigationBar 위쪽 공간에 배치해주므로,
      // 화면 안쪽 BaseScaffold의 SafeArea가 세이프 에어리어를 또 더하지
      // 않도록 여기서 bottom padding을 명시적으로 제거한다.
      body: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: navigationShell,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
      ),
    );
  }
}
