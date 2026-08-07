import 'package:flutter/material.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';

/// 아직 화면이 없는 하단 탭(자료방, 캘린더 등)의 임시 목적지.
class ComingSoonPage extends StatelessWidget {
  final String title;

  const ComingSoonPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppBar(title: title, showBackButton: false),
      child: Center(child: Text('준비 중이에요', style: AppTextStyle.subText)),
    );
  }
}
