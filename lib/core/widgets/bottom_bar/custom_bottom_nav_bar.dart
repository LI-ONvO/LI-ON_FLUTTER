import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:li_on/core/constants/color.dart';

class _NavItem {
  final String label;
  final String asset;

  const _NavItem({required this.label, required this.asset});
}

const List<_NavItem> _navItems = [
  _NavItem(label: '탐색', asset: 'assets/icons/nav/nav_search.svg'),
  _NavItem(label: '로드맵', asset: 'assets/icons/nav/nav_roadmap.svg'),
  _NavItem(label: '자료방', asset: 'assets/icons/nav/nav_materials.svg'),
  _NavItem(label: '캘린더', asset: 'assets/icons/nav/nav_calendar.svg'),
  _NavItem(label: '프로필', asset: 'assets/icons/nav/nav_profile.svg'),
];

const int _navItemCount = 5;

/// 선택 상태를 직접 들고 있지 않는 컨트롤드 위젯. 실제로 어떤 탭이 선택된
/// 상태인지는 [AppShell]이 라우터의 현재 위치([currentIndex])로부터 결정해
/// 전달하므로, 탭을 눌러도 실제 이동 없이 하이라이트만 바뀌는 문제가 생기지
/// 않는다.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  }) : assert(
         currentIndex >= 0 && currentIndex < _navItemCount,
         'currentIndex must be between 0 and ${_navItemCount - 1}',
       );

  @override
  Widget build(BuildContext context) {
    assert(
      _navItems.length == _navItemCount,
      '_navItemCount must match _navItems.length',
    );
    // 화면 하단에 바로 붙는 위젯이라 기기의 홈 인디케이터 세이프 에어리어를
    // 직접 챙긴다. 이 위젯을 감싸는 쪽(BaseScaffold 등)이 SafeArea를
    // 대신 처리해줄 거라고 가정하지 않는다.
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 9, bottom: 10),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.background, width: 1),
          ),
        ),
        child: Row(
          children: [
            for (int i = 0; i < _navItems.length; i++)
              Expanded(
                child: _NavBarItem(
                  item: _navItems[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.primary : AppColors.subText;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            item.asset,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(top: 1, bottom: 2),
            child: Text(
              item.label,
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
