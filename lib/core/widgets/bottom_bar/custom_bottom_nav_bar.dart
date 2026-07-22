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

class CustomBottomNavBar extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<int>? onTap;

  const CustomBottomNavBar({
    super.key,
    this.initialIndex = 0,
    this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late int _currentIndex = widget.initialIndex;

  void _handleTap(int index) {
    setState(() => _currentIndex = index);
    widget.onTap?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 9, bottom: 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.background, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < _navItems.length; i++)
            _NavBarItem(
              item: _navItems[i],
              selected: i == _currentIndex,
              onTap: () => _handleTap(i),
            ),
        ],
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
