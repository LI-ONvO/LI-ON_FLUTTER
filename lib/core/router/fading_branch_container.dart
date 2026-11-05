import 'package:flutter/material.dart';

/// 하단 탭을 바꿀 때 걸리는 시간.
const Duration _fadeDuration = Duration(milliseconds: 200);

/// 하단 탭 화면들을 담는 컨테이너. go_router 기본(IndexedStack)처럼 모든 탭의
/// 상태를 유지하되, 탭을 바꿀 때 화면이 툭 바뀌지 않고 서서히 겹쳐 바뀐다.
class FadingBranchContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const FadingBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  State<FadingBranchContainer> createState() => _FadingBranchContainerState();
}

class _FadingBranchContainerState extends State<FadingBranchContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _fadeDuration,
    value: 1,
  )..addStatusListener(_onStatusChanged);

  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  late final Animation<double> _fadeOut = ReverseAnimation(_fadeIn);

  /// 전환 중 사라지고 있는 탭. 전환이 끝나면 null.
  int? _leavingIndex;

  @override
  void didUpdateWidget(FadingBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _leavingIndex = null;
      _controller.value = 1;
      return;
    }
    _leavingIndex = oldWidget.currentIndex;
    _controller.forward(from: 0);
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status.isCompleted && _leavingIndex != null) {
      setState(() => _leavingIndex = null);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 두 화면 중 위에 그려지는 쪽만 투명도를 바꾼다. 아래 화면은 불투명하게
  /// 두어야 전환 중에 배경이 비쳐 깜빡이지 않는다. 순서를 바꾸지 않으므로
  /// 탭 화면의 상태도 그대로 유지된다.
  Animation<double> _opacityOf(int index) {
    final int current = widget.currentIndex;
    final int? leaving = _leavingIndex;
    if (leaving == null) return kAlwaysCompleteAnimation;
    if (index == current && current > leaving) return _fadeIn;
    if (index == leaving && leaving > current) return _fadeOut;
    return kAlwaysCompleteAnimation;
  }

  /// 감싸는 위젯의 구조는 전환 여부와 관계없이 항상 같게 둔다. 구조가 바뀌면
  /// 그 아래 탭 화면이 새로 만들어져 스크롤 위치 같은 상태를 잃는다.
  Widget _buildBranch(int index, Widget child) {
    final bool isCurrent = index == widget.currentIndex;
    final bool isLeaving = index == _leavingIndex;
    return Offstage(
      offstage: !isCurrent && !isLeaving,
      child: IgnorePointer(
        ignoring: !isCurrent,
        child: ExcludeSemantics(
          excluding: !isCurrent,
          child: FadeTransition(
            opacity: _opacityOf(index),
            child: TickerMode(enabled: isCurrent, child: child),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (int i = 0; i < widget.children.length; i++)
          _buildBranch(i, widget.children[i]),
      ],
    );
  }
}
