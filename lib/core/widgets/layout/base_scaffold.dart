import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomBar;
  const BaseScaffold({
    super.key,
    required this.child,
    required this.appBar,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: bottomBar,
              ),
            ),
    );
  }
}
