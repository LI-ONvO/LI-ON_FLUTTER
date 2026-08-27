import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/auth/provider/auth_session.dart';
import 'package:li_on/pages/auth/model/auth_user.dart';

/// 스플래시 로고의 한 변 길이. 원본 SVG가 800×800이라 크기를 지정하지 않으면
/// 그 고유 크기 그대로 그려져 화면이 낮을 때 Column을 넘치므로 명시해 둔다.
const double _logoSize = 160;

/// 로고를 보여 주는 시간.
const Duration _splashDuration = Duration(seconds: 2);

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _continue();
  }

  Future<void> _continue() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final Future<String?> accessToken = tokenStorage.readAccessToken();
    final Future<AuthUser?> user = tokenStorage.readUser();
    final List<Object?> results = await Future.wait<Object?>([
      accessToken,
      user,
      Future<void>.delayed(_splashDuration),
    ]);
    if (!mounted) return;
    final String? storedAccessToken = results[0] as String?;
    final AuthUser? storedUser = results[1] as AuthUser?;
    if (storedAccessToken?.isNotEmpty == true) {
      ref.read(authSessionProvider).restore(storedUser);
      context.go('/search');
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/images/lion.svg',
              width: _logoSize,
              height: _logoSize,
            ),
          ),
        ],
      ),
    );
  }
}
