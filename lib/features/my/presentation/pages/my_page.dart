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
import 'package:li_on/features/auth/data/auth_repository.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/features/certificate_search/presentation/widgets/recommendation_section.dart';
import 'package:li_on/features/my/data/profile.dart';
import 'package:li_on/features/my/data/user_repository.dart';
import 'package:li_on/features/my/presentation/widgets/custom_bottom_sheet.dart';
import 'package:li_on/features/my/presentation/widgets/menu.dart';
import 'package:li_on/features/my/presentation/widgets/my_page_profile.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  Profile _profile = const Profile(
    id: 0,
    email: '',
    nickname: '사용자',
    desiredFields: [],
    isOnboarded: false,
  );

  String get _explanation {
    if (_profile.desiredFields.isEmpty) return '희망 분야를 설정해주세요';
    return _profile.desiredFields.map((field) => field.name).join(', ');
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// 서버에 저장된 실제 프로필(회원가입 때 입력한 닉네임 포함)을 불러온다.
  /// 실패하면 기본값을 그대로 유지한다.
  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(userRepositoryProvider).fetchMyProfile();
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (_) {}
  }

  Future<void> _openEditProfileSheet(BuildContext context) async {
    final ProfileEditResult? result =
        await showAppBottomSheet<ProfileEditResult>(
          context: context,
          builder: (context) => CustomBottomSheet(
            name: _profile.nickname,
            email: _profile.email,
            desiredFields: _profile.desiredFields,
          ),
        );
    if (result == null || !mounted) return;
    setState(() {
      _profile = Profile(
        id: _profile.id,
        email: _profile.email,
        nickname: result.name,
        desiredFields: result.desiredFields,
        isOnboarded: _profile.isOnboarded,
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
    // 새로고침 없이 바로 갱신한다. 수정 시트(_openEditProfileSheet)는
    // 아직 서버에 저장하지 않는 로컬 편집이라 이 provider와는 무관하다.
    ref.listen<AsyncValue<Profile>>(myProfileProvider, (previous, next) {
      next.whenData((profile) {
        if (mounted) setState(() => _profile = profile);
      });
    });

    return BaseScaffold(
      appBar: CustomAppBar(title: '내 정보', showBackButton: false),
      child: SingleChildScrollView(
        child: Column(
          children: [
            MyPageProfile(
              nickname: _profile.nickname,
              explanation: _explanation,
              onEditTap: () => _openEditProfileSheet(context),
            ),
            // 회원가입 직후 온보딩 제출이 실패했거나 건너뛴 계정을 위한
            // 안내. 서버가 내려주는 isOnboarded를 그대로 신뢰해, 추천을
            // 눌러봐서 409를 만나기 전에 먼저 다시 할 수 있게 안내한다.
            if (!_profile.isOnboarded) ...[
              const SizedBox(height: AppSpacing.space3),
              _OnboardingReminderBanner(
                onTap: () => context.push('/onboarding'),
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
              onTap: () => context.push('/onboarding'),
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
