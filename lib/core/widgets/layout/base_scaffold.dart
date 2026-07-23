import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  const BaseScaffold({super.key,required this.child,required this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: child,
      ),
    );
  }
}
