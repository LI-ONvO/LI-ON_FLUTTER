import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';

/// 태블릿·웹처럼 폭이 넓은 화면에서 시트가 과하게 늘어나지 않도록 제한한다.
const double _maxSheetWidth = 640;

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
    return SafeArea(
      top: false,
      // heightFactor 1로 내용 높이만큼만 차지해야 시트가 화면 가운데로 뜨지
      // 않고 하단에 붙는다. 가로는 넓은 화면에서 가운데 정렬된다.
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _maxSheetWidth,
            // 키보드가 올라오거나 내용이 길어져도 시트가 상태바 아래까지
            // 차오르지 않도록 제한한다.
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Padding(
            // 키보드가 올라온 만큼 시트를 밀어 올려 입력창이 가리지 않게 한다.
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
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
