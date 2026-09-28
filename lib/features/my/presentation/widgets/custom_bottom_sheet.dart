import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/core/network/token_storage.dart';
import 'package:li_on/core/utils/validators.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/features/my/data/info_edit.dart';
import 'package:li_on/features/my/data/user_repository.dart';

/// 내 정보(닉네임) 수정 시트. 서버에 저장까지 끝나면 저장된 닉네임을
/// 돌려주며 닫힌다.
///
/// 희망 분야는 서버가 온보딩 답변으로 정하는 값이라 여기서 고치지 않고,
/// 마이페이지의 "희망 분야 수정"(온보딩 다시하기)으로 바꾼다.
class CustomBottomSheet extends ConsumerStatefulWidget {
  final String name;
  final String email;

  const CustomBottomSheet({super.key, required this.name, required this.email});

  @override
  ConsumerState<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends ConsumerState<CustomBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.name,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.email,
  );
  bool _isSaving = false;

  /// 저장 실패 사유. 시트가 루트 Navigator에 떠 있어 스낵바는 시트 뒤에
  /// 가려지므로, 시트 안에 직접 보여준다.
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final String name = _nameController.text.trim();
    if (name == widget.name) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    // 저장 중에 사용자가 시트를 쓸어내려 닫으면 이 위젯의 ref는 더 이상
    // 쓸 수 없다. 서버 저장이 끝난 뒤의 후속 처리는 시트가 닫혀도 해야
    // 하므로, 필요한 것을 기다리기 전에 미리 잡아 둔다.
    final ProviderContainer container = ProviderScope.containerOf(context);
    final UserRepository repository = ref.read(userRepositoryProvider);
    final AuthSessionController session = ref.read(authSessionProvider);
    final TokenStorage storage = ref.read(tokenStorageProvider);
    try {
      final InfoEditResponse response = await repository.updateInfo(
        InfoEditRequest(nickname: name),
      );
      // 탐색 화면 인사말 등은 로그인 때 기기에 저장해 둔 사용자 정보를
      // 쓰므로, 앱을 다시 켜도 바뀐 닉네임이 보이도록 함께 갱신한다.
      // 서버에는 이미 저장됐으니, 기기 저장소 쓰기가 실패해도 저장 자체는
      // 성공으로 처리한다(다음 프로필 조회 때 다시 맞춰진다).
      try {
        await syncSessionNickname(session, storage, response.nickname);
      } catch (error) {
        debugPrint('[profile] 닉네임을 기기에 저장하지 못했어요: $error');
      }
      container.invalidate(myProfileProvider);
      if (!mounted) return;
      Navigator.of(context).pop<String>(response.nickname);
    } on ApiException catch (exception) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = exception.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        // 키보드가 올라온 만큼 시트를 밀어 올려 입력창·저장 버튼이 가리지
        // 않게 한다.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 14),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text('내 정보 수정', style: AppTextStyle.section),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(Icons.close, color: AppColors.text),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                CustomTextField(
                  label: '이름',
                  hintText: '',
                  controller: _nameController,
                  validator: (value) => Validators.nickname(value?.trim()),
                ),
                const SizedBox(height: AppSpacing.space3),
                CustomTextField(
                  label: '이메일',
                  hintText: '',
                  controller: _emailController,
                  enabled: false,
                  fillColor: AppColors.surface,
                ),
                const SizedBox(height: AppSpacing.space3),
                GestureDetector(
                  // 비밀번호 변경 화면이 아직 없어, 무반응 대신 준비 중임을
                  // 알린다.
                  onTap: () => CustomSnackbar.show(
                    context,
                    message: '아직 준비 중인 기능이에요',
                    type: SnackbarType.info,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '비밀번호 변경',
                        style: AppTextStyle.mainText.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_sharp,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: AppTextStyle.mainText.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                ],
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space4),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nameController,
                    builder: (context, value, _) {
                      final bool canSave =
                          value.text.trim().isNotEmpty && !_isSaving;
                      return CustomElevatedButton(
                        text: _isSaving ? '저장 중...' : '저장',
                        backgroundColor: AppColors.primary,
                        onPressed: canSave ? _save : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
