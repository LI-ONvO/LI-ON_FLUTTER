import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';

/// 프레임 안쪽 화면의 폭. 큰 휴대폰 화면과 비슷하게 잡아, 모바일에서 보던
/// 여백과 글자 크기가 웹에서도 그대로 유지되게 한다.
const double _frameWidth = 430;

/// 이 폭보다 좁으면 프레임을 씌우지 않는다. 휴대폰·좁은 창 브라우저는
/// 지금처럼 화면 전체를 쓰는 편이 자연스럽다.
const double _wideBreakpoint = 600;

/// 웹에서 창이 넓어져도 화면이 옆으로 늘어나지 않도록, 앱 전체를 휴대폰 폭
/// 만큼만 가운데에 두는 프레임.
///
/// [MaterialApp.builder]로 네비게이터 바깥에 한 번만 씌우므로, 모든 화면과
/// 바텀시트가 자동으로 이 프레임 안에 들어온다.
class WebFrame extends StatelessWidget {
  final Widget child;

  const WebFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    if (!kIsWeb || size.width < _wideBreakpoint) return child;

    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Container(
          width: _frameWidth,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border.symmetric(
              vertical: BorderSide(color: AppColors.divider),
            ),
          ),
          // 프레임 밖으로 내용이 삐져나오지 않게 잘라낸다.
          child: ClipRect(
            child: MediaQuery(
              // 바텀시트처럼 화면 크기를 기준으로 크기를 정하는 위젯이
              // 브라우저 창이 아니라 이 프레임을 화면으로 여기게 한다.
              data: MediaQuery.of(
                context,
              ).copyWith(size: Size(_frameWidth, size.height)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
