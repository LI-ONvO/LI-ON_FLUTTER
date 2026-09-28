import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/core/auth/auth_user.dart';

/// 스플래시 로고의 한 변 길이. Android 12+ 시스템 스플래시는 아이콘 배경색이 화면
/// 배경색(흰색)과 같으면 배경을 생략하고 적응형 아이콘의 108dp 캔버스를 288dp로
/// 키워 그린다. 전경 이미지(assets/icon/app_icon_foreground.png)에서 SVG가
/// 1024px 중 537px을 차지하므로 288 × 537 / 1024 ≈ 151dp가 된다. 같은 크기·같은
/// 위치(화면 정중앙)로 그려야 시스템 스플래시에서 이 화면으로 넘어갈 때 로고가
/// 튀지 않는다.
const double _logoSize = 151;

const String _logoAsset = 'assets/images/lion.svg';

/// 스플래시 로고 SVG를 미리 읽어 둔다. [SvgPicture]는 비동기로 로드되어 첫
/// 프레임에 로고가 비어 있으므로, runApp 전에 호출해 시스템 스플래시가 사라진
/// 직후 흰 화면이 잠깐 보이는 것을 막는다.
Future<void> precacheSplashLogo() async {
  const SvgAssetLoader loader = SvgAssetLoader(_logoAsset);
  await svg.cache.putIfAbsent(
    loader.cacheKey(null),
    () => loader.loadBytes(null),
  );
}

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
    // 시스템 스플래시처럼 상태바·내비게이션 바를 포함한 전체 화면의 정중앙에
    // 두기 위해 SafeArea가 있는 BaseScaffold 대신 전체 화면을 채운다.
    return ColoredBox(
      color: AppColors.white,
      child: Center(
        child: SvgPicture.asset(
          _logoAsset,
          width: _logoSize,
          height: _logoSize,
        ),
      ),
    );
  }
}
