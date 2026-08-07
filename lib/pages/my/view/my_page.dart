import 'package:flutter/material.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/model/job_field.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/my/model/profile.dart';
import 'package:li_on/pages/my/widget/custom_bottom_sheet.dart';
import 'package:li_on/pages/my/widget/menu.dart';
import 'package:li_on/pages/my/widget/my_page_profile.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 로그인 기능이 아직 없어 임시로 고정값을 사용한다.
  Profile _profile = Profile(
    id: 1,
    email: 'seungwoo@example.com',
    nickname: '최승우',
    job: jobOptions[0],
    desiredFields: [desiredFieldOptions[0]],
    isOnboarded: true,
  );

  String get _explanation {
    final List<String> parts = [
      if (_profile.desiredFields.isNotEmpty)
        _profile.desiredFields.map((field) => field.name).join(', '),
      if (_profile.job != null) '${_profile.job!.name} 희망',
    ];
    return parts.isEmpty ? '희망 분야를 설정해주세요' : parts.join(' · ');
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
            job: _profile.job,
            desiredFields: _profile.desiredFields,
          ),
        );
    if (result == null || !mounted) return;
    setState(() {
      _profile = Profile(
        id: _profile.id,
        email: _profile.email,
        nickname: result.name,
        job: result.job,
        desiredFields: result.desiredFields,
        isOnboarded: _profile.isOnboarded,
      );
    });
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
            Menu(menu: '희망 분야 수정', icon: Icons.person_outline),
            Menu(menu: '알림 설정', icon: Icons.notifications_outlined),
            Menu(menu: '이용약관', icon: Icons.article_outlined),
            Menu(menu: '로그아웃', icon: Icons.exit_to_app),
          ],
        ),
      ),
    );
  }
}
