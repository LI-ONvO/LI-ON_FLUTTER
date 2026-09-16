import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/dialog/confirm_dialog.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/auth/login/provider/login_view_model.dart';
import 'package:li_on/pages/auth/provider/auth_repository.dart';
import 'package:li_on/pages/auth/provider/auth_session.dart';
import 'package:li_on/pages/auth/sign_up/provider/sign_in_view_model.dart';
import 'package:li_on/pages/calendar/provider/calendar_repository.dart';
import 'package:li_on/pages/calendar/provider/calendar_view_model.dart';
import 'package:li_on/pages/certificate_search/provider/certificate_search_view_model.dart';
import 'package:li_on/pages/data_room/provider/data_room_repository.dart';
import 'package:li_on/pages/data_room/provider/data_room_view_model.dart';
import 'package:li_on/pages/my/model/profile.dart';
import 'package:li_on/pages/my/widget/custom_bottom_sheet.dart';
import 'package:li_on/pages/my/widget/menu.dart';
import 'package:li_on/pages/my/widget/my_page_profile.dart';
import 'package:li_on/pages/roadmap/chat_history/provider/chat_history_view_model.dart';
import 'package:li_on/pages/roadmap/roadmap_chat/provider/roadmap_chat_view_model.dart';

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

  Future<void> _openEditProfileSheet(BuildContext context) async {
    final ProfileEditResult? result =
        await showModalBottomSheet<ProfileEditResult>(
          context: context,
          // MyPage는 go_router 셸 브랜치의 중첩 Navigator 안에 있다. 루트가
          // 아닌 그 Navigator에 시트를 띄우면 화면 전체가 아니라 브랜치
          // 영역(하단 탭바 위, 상태바 세이프에어리어 미적용 영역)에만 걸쳐서
          // 뜨기 때문에, 최상위 Navigator를 명시해 화면 전체를 덮게 한다.
          useRootNavigator: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: 0.4),
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
    if (!context.mounted) return;
    // 저장된 토큰과 사용자별 메모리 상태를 지워, 다른 계정에 이전 데이터가
    // 보이지 않게 한다. 저장소도 폐기해야 다음 조회에서 새 더미/API 데이터를 쓴다.
    await ref.read(tokenStorageProvider).clear();
    ref.read(authSessionProvider).signOut();
    ref.read(loginViewModelProvider.notifier).reset();
    ref.read(signInViewModelProvider.notifier).reset();
    ref.invalidate(certificateSearchViewModelProvider);
    ref.invalidate(dataRoomFilterProvider);
    ref.invalidate(dataRoomMaterialsProvider);
    ref.invalidate(dataRoomRepositoryProvider);
    ref.invalidate(calendarEventsProvider);
    ref.invalidate(calendarEventRepositoryProvider);
    ref.invalidate(chatHistoryViewModelProvider);
    ref.invalidate(roadmapChatViewModelProvider);
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: AppSpacing.space5),
            Menu(
              menu: '희망 분야 수정',
              icon: Icons.person_outline,
              statusLabel: '준비 중',
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
