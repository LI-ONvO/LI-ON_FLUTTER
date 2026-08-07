import 'package:flutter/material.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class Menu extends StatelessWidget {
  final IconData icon;
  final String menu;
  final VoidCallback? onTap;

  const Menu({super.key, required this.menu, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: AppSpacing.space2),
                Text(menu, style: AppTextStyle.card),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_sharp),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
