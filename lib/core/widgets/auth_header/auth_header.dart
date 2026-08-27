import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.space2),
        Center(
          child: SvgPicture.asset(
            'assets/images/lion.svg',
            width: 100,
            height: 100,
          ),
        ),
        const SizedBox(height: AppSpacing.space1),
        Text('자격증 학습, 로드맵부터 계획까지', style: AppTextStyle.mainText),
      ],
    );
  }
}
