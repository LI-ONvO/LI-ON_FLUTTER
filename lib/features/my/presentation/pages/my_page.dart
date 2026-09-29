import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/core/notification/device_token_repository.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/dialog/confirm_dialog.dart';
import 'package:li_on/core/widgets/layout/app_bottom_sheet.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/features/auth/data/auth_repository.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/features/certificate_search/presentation/widgets/recommendation_section.dart';
import 'package:li_on/features/my/data/profile.dart';
import 'package:li_on/features/my/data/user_repository.dart';
import 'package:li_on/features/my/presentation/widgets/custom_bottom_sheet.dart';
import 'package:li_on/features/my/presentation/widgets/menu.dart';
import 'package:li_on/features/my/presentation/widgets/my_page_profile.dart';
import 'package:li_on/features/onboarding/presentation/pages/onboarding_page.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  /// 서버에서 받은 프로필. 불러오기 전(또는 실패 시)에는 null이며, 그동안
  /// 기본값("사용자", 온보딩 미완료 배너)을 보여주면 저장한 닉네임이
  /// 사라진 것처럼 보이므로 세션의 닉네임을 대신 쓰고 배너는 숨긴다.
  Profile? _profile;

  String get _nickname =>
      _profile?.nickname ??
      ref.read(authSessionProvider).user?.nickname ??
      '사용자';

  String get _explanation {
    final Profile? profile = _profile;
    if (profile == null) return '';
    if (profile.desiredFields.isEmpty) return '희망 분야를 설정해주세요';
    return profile.desiredFields.map((field) => field.name).join(', ');
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// 서버에 저장된 실제 프로필(회원가입 때 입력한 닉네임 포함)을 불러온다.
  /// 실패하면 세션의 닉네임을 그대로 보여주고, 수정 버튼을 누를 때 다시
  /// 시도한다([_onEditTap]).
  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(userRepositoryProvider).fetchMyProfile();
      if (!mounted) return;
      _applyProfile(profile);
    } catch (_) {}
  }

  /// 서버에서 받은 프로필을 화면에 반영하고, 다른 기기에서 닉네임을 바꾼
  /// 경우처럼 세션의 닉네임이 서버와 다르면 함께 맞춘다.
  void _applyProfile(Profile profile) {
    setState(() => _profile = profile);
    // 화면 표시에는 영향이 없는 보조 동기화라, 기기 저장소 쓰기가 실패해도
    // 무시한다(다음 조회 때 다시 시도된다).
    syncSessionNickname(
      ref.read(authSessionProvider),
      ref.read(tokenStorageProvider),
      profile.nickname,
    ).catchError((Object error) {
      debugPrint('[profile] 닉네임을 기기에 저장하지 못했어요: $error');
    });
  }

  /// 프로필을 아직 못 불러왔다면(네트워크 오류 등) 수정 시트를 열기 전에
  /// 한 번 더 불러오고, 그래도 실패하면 이유를 알린다.
  Future<void> _onEditTap(BuildContext context) async {
    if (_profile == null) await _loadProfile();
    if (!context.mounted) return;
    final Profile? profile = _profile;
    if (profile == null) {
      CustomSnackbar.show(
        context,
        message: '내 정보를 불러오지 못했어요. 잠시 후 다시 시도해주세요',
        type: SnackbarType.error,
      );
      return;
    }
    await _openEditProfileSheet(context, profile);
  }

  Future<void> _openEditProfileSheet(
    BuildContext context,
    Profile profile,
  ) async {
    final String? savedNickname = await showAppBottomSheet<String>(
      context: context,
      builder: (context) =>
          CustomBottomSheet(name: profile.nickname, email: profile.email),
    );
    if (savedNickname == null || !mounted) return;
    // 시트가 myProfileProvider를 invalidate해 곧 서버 값으로 다시 갱신되지만,
    // 그 전에도 바뀐 닉네임이 바로 보이게 먼저 반영한다.
    setState(() {
      _profile = Profile(
        id: profile.id,
        email: profile.email,
        nickname: savedNickname,
        desiredFields: profile.desiredFields,
        isOnboarded: profile.isOnboarded,
      );
    });
  }

  /// 로그아웃을 한 번 더 확인받고, 확인하면 로그인 화면으로 돌아간다.
  /// go_router 스택 전체를 대체해 로그아웃 후 뒤로가기로 이전 화면에
  /// 남지 않게 한다.
  Future<void> _logout(BuildContext context) async {
    final bool confirmed = await ConfirmDialog.show(
      context,
      icon: Icons.exit_to_app,
      title: '로그아웃 하시겠어요?',
      description: '다시 로그인해야 이용할 수 있어요.',
      confirmText: '로그아웃',
    );
    if (!confirmed || !context.mounted) return;
    // 서버의 refreshToken을 무효화한다. 실패해도 로컬 로그아웃은 계속
    // 진행해, 네트워크 문제로 로그아웃이 막히지 않게 한다.
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {}
    // 이 기기의 FCM 토큰을 해제한다. accessToken이 지워지기 전에 호출해야 한다.
    await unregisterCurrentDeviceToken(ref.read(deviceTokenRepositoryProvider));
    if (!context.mounted) return;
    await ref.read(tokenStorageProvider).clear();
    // 사용자별 캐시 정리는 signOut을 감지하는 user_scoped_state_reset.dart에서 한다.
    ref.read(authSessionProvider).signOut();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    // 온보딩을 마이페이지에서 다시 제출하면(onboarding_page.dart) 이
    // provider를 invalidate한다. 그 갱신을 받아 배너·희망 분야 문구를
    // 새로고침 없이 바로 갱신한다. 닉네임 수정 시트(_openEditProfileSheet)도
    // 서버 저장 후 이 provider를 invalidate한다.
    ref.listen<AsyncValue<Profile>>(myProfileProvider, (previous, next) {
      next.whenData((profile) {
        if (mounted) _applyProfile(profile);
      });
    });

    final Profile? profile = _profile;

    return BaseScaffold(
      appBar: CustomAppBar(title: '내 정보', showBackButton: false),
      child: SingleChildScrollView(
        child: Column(
          children: [
            MyPageProfile(
              nickname: _nickname,
              explanation: _explanation,
              onEditTap: () => _onEditTap(context),
            ),
            // 회원가입 직후 온보딩 제출이 실패했거나 건너뛴 계정을 위한
            // 안내. 서버가 내려주는 isOnboarded를 그대로 신뢰해, 추천을
            // 눌러봐서 409를 만나기 전에 먼저 다시 할 수 있게 안내한다.
            if (profile != null && !profile.isOnboarded) ...[
              const SizedBox(height: AppSpacing.space3),
              _OnboardingReminderBanner(
                onTap: () => pushOnboardingForEdit(context, ref),
              ),
            ],
            const SizedBox(height: AppSpacing.space5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('나에게 맞는 자격증', style: AppTextStyle.section),
            ),
            const SizedBox(height: AppSpacing.space2),
            const RecommendationSection(),
            const SizedBox(height: AppSpacing.space5),
            Menu(
              menu: '희망 분야 수정',
              icon: Icons.person_outline,
              onTap: () => pushOnboardingForEdit(context, ref),
            ),
            Menu(
              menu: '알림 설정',
              icon: Icons.notifications_outlined,
              statusLabel: '준비 중',
            ),
            Menu(
              menu: '이용약관',
              icon: Icons.article_outlined,
              statusLabel: '준비 중',
            ),
            Menu(
              menu: '로그아웃',
              icon: Icons.exit_to_app,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// 온보딩이 아직 안 된(또는 실패해서 안 된 채로 남은) 계정에게 보여주는
/// 안내 배너. 누르면 언제든 다시 온보딩을 할 수 있는 `/onboarding`으로 이동.
class _OnboardingReminderBanner extends StatelessWidget {
  const _OnboardingReminderBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.space2),
            Expanded(
              child: Text(
                '온보딩이 완료되지 않았어요 · 눌러서 다시하기',
                style: AppTextStyle.mainText,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
