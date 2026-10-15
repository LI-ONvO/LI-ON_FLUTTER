import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';

/// 앱 공통 원형 로딩 인디케이터. primary 색으로 가운데에 그린다.
class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
