import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

/// 태블릿·웹처럼 폭이 넓은 화면에서 시트가 과하게 늘어나지 않도록 제한한다.
const double _maxSheetWidth = 640;

/// 앱의 바텀시트를 공통 설정으로 띄운다.
///
/// 탭 화면은 go_router 셸 브랜치의 중첩 Navigator 안에 있어, 그 Navigator에
/// 띄우면 하단 탭바 위 영역에만 걸친다. 최상위 Navigator에 띄워 화면 전체를
/// 덮고, 배경은 투명하게 두어 [AppBottomSheet]의 둥근 모서리가 보이게 한다.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: builder,
  );
}

/// 앱 바텀시트의 공통 골격. 손잡이 바·제목·닫기 버튼과 화면 하단에 붙는
/// 배치를 맡고, 그 아래 내용은 [children]으로 받는다.
///
/// 내용이 길어질 수 있는 시트는 [children]에 [Flexible]로 감싼 스크롤 영역을
/// 넘겨야 시트가 화면 위로 넘치지 않는다.
class AppBottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    // 모달 라우트는 MediaQuery의 위쪽 여백을 지우므로 상태바 높이는 뷰에서
    // 직접 읽는다.
    final double statusBarHeight = MediaQueryData.fromView(
      View.of(context),
    ).padding.top;
    // 키보드를 뺀 남은 공간 안에서만 시트가 자라도록 한다. 키보드 높이를
    // 최대 높이 안쪽에서 빼면 스크롤 영역이 너무 좁아져 입력창이 잘린다.
    final double maxSheetHeight = math.min(
      screenSize.height * 0.85,
      screenSize.height - keyboardHeight - statusBarHeight - AppSpacing.space2,
    );

    return SafeArea(
      top: false,
      // heightFactor 1로 내용 높이만큼만 차지해야 시트가 화면 가운데로 뜨지
      // 않고 하단에 붙는다. 가로는 넓은 화면에서 가운데 정렬된다.
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: Padding(
          // 키보드가 올라온 만큼 시트를 밀어 올려 입력창이 가리지 않게 한다.
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _maxSheetWidth,
              maxHeight: maxSheetHeight,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 14),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Text(title, style: AppTextStyle.section),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(Icons.close, color: AppColors.text),
                      ),
                    ],
                  ),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 바텀시트 안 입력 항목의 라벨.
class SheetLabel extends StatelessWidget {
  final String text;

  const SheetLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyle.subText.copyWith(fontSize: 13)),
    );
  }
}
