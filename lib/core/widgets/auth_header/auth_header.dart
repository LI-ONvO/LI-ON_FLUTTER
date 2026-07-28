import 'package:flutter/widgets.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Certipath', style: AppTextStyle.bold),
        const SizedBox(height: AppSpacing.space1),
        Text('자격증 학습, 로드맵부터 계획까지', style: AppTextStyle.mainText),
      ],
    );
  }
}
