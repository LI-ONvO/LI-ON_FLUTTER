import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/core/utils/auth_form_submit.dart';
import 'package:li_on/core/utils/validators.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/features/auth/data/auth_repository.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/features/auth/presentation/view_models/sign_in_view_model.dart';

/// 회원가입 2단계: 발송된 인증코드를 확인하고, 확인되면 1단계에서 모아둔
/// 정보로 실제 회원가입까지 이어서 처리한다.
class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // 회원가입 1단계를 거치지 않고 주소로 바로 들어오면 가입에 필요한
    // 정보(이메일·비밀번호 등)가 없으므로 회원가입 화면으로 돌려보낸다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final SignInState formState = ref.read(signInViewModelProvider);
      if (formState.email.isEmpty || formState.password.isEmpty) {
        context.go('/sign-up');
      }
    });
  }

  /// 가입 완료 요청이 진행 중인지. 버튼을 비활성화해 중복 제출을 막는다.
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final SignInViewModel viewModel = ref.read(
        signInViewModelProvider.notifier,
      );
      final SignInState formState = ref.read(signInViewModelProvider);
      final authRepository = ref.read(authRepositoryProvider);

      final bool isValid = await submitAuthForm(
        context: context,
        formKey: _formKey,
        onSubmitted: viewModel.markSubmitted,
        successMessage: '회원가입이 완료되었습니다',
        onValid: () async {
          final verification = await authRepository.verifyEmailCode(
            email: formState.email,
            code: formState.verificationCode,
          );
          if (!verification.verified) {
            throw const ApiException(message: '인증 코드가 올바르지 않아요');
          }
          // 서버가 이메일 인증 상태를 이메일 기준으로 들고 있어, 가입 요청에
          // 별도 인증 토큰을 함께 보내지 않는다.
          await authRepository.signUp(
            email: formState.email,
            password: formState.password,
            passwordConfirm: formState.passwordConfirm,
            nickname: formState.nickname,
          );
        },
      );
      if (!mounted) return;
      if (!isValid) return;
      ref.read(authSessionProvider).startOnboarding();
      context.go('/onboarding');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SignInState formState = ref.watch(signInViewModelProvider);
    final SignInViewModel viewModel = ref.read(
      signInViewModelProvider.notifier,
    );

    return BaseScaffold(
      appBar: CustomAppBar(title: '이메일 인증'),
      bottomBar: CustomElevatedButton(
        onPressed: formState.isVerificationCodeFilled && !_isSubmitting
            ? _submit
            : null,
        text: '가입 완료',
        backgroundColor: AppColors.primary,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space4),
              Text(
                '${formState.email}로\n인증 코드를 보냈어요',
                style: AppTextStyle.mainText,
              ),
              const SizedBox(height: AppSpacing.space4),
              CustomTextField(
                key: const Key('verificationCodeField'),
                label: '인증 코드',
                hintText: '숫자 6자리 입력',
                keyboardType: TextInputType.number,
                validator: Validators.verificationCode,
                autovalidateMode: formState.autovalidateMode,
                onChanged: viewModel.setVerificationCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
