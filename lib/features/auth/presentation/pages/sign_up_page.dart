import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/utils/auth_form_submit.dart';
import 'package:li_on/core/utils/validators.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/auth_header/auth_header.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/core/widgets/text_field/email_field.dart';
import 'package:li_on/features/auth/data/auth_repository.dart';
import 'package:li_on/features/auth/presentation/view_models/sign_in_view_model.dart';

/// 이메일·비밀번호·닉네임을 입력받는 회원가입 1단계 화면.
/// 인증코드 발송에 성공하면 이메일 인증 화면(2단계)으로 넘어간다.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// 인증 메일 발송 요청이 진행 중인지. 버튼을 비활성화해 중복 제출을 막는다.
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final SignInViewModel viewModel = ref.read(
        signInViewModelProvider.notifier,
      );
      final SignInState formState = ref.read(signInViewModelProvider);
      final bool isValid = await submitAuthForm(
        context: context,
        formKey: _formKey,
        onSubmitted: viewModel.markSubmitted,
        successMessage: '인증 메일을 보냈습니다',
        onValid: () => ref
            .read(authRepositoryProvider)
            .sendEmailVerificationCode(email: formState.email),
      );
      if (!mounted) return;
      if (!isValid) return;
      context.push('/sign-up/verify-email');
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
      appBar: CustomAppBar(title: '회원가입'),
      bottomBar: CustomElevatedButton(
        onPressed: formState.isFilled && !_isSubmitting ? _submit : null,
        text: '메일 인증 받기',
        backgroundColor: AppColors.primary,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeader(),
            const SizedBox(height: AppSpacing.space6),
            Form(
              key: _formKey,
              child: Column(
                spacing: AppSpacing.space2,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmailField(
                    autovalidateMode: formState.autovalidateMode,
                    onChanged: viewModel.setEmail,
                  ),
                  CustomTextField(
                    key: const Key('nicknameField'),
                    label: '닉네임',
                    hintText: '2~10자로 입력해주세요',
                    validator: Validators.nickname,
                    autovalidateMode: formState.autovalidateMode,
                    onChanged: viewModel.setNickname,
                    textInputAction: TextInputAction.next,
                  ),
                  CustomTextField(
                    key: const Key('passwordField'),
                    label: '비밀번호',
                    hintText: '영문·숫자·특수문자 포함 8자 이상',
                    obscureText: true,
                    validator: Validators.password,
                    autovalidateMode: formState.autovalidateMode,
                    onChanged: viewModel.setPassword,
                    textInputAction: TextInputAction.next,
                  ),
                  CustomTextField(
                    key: const Key('passwordConfirmField'),
                    label: '비밀번호 확인',
                    hintText: '위 비밀번호와 동일하게 입력',
                    obscureText: true,
                    validator: (value) =>
                        Validators.passwordConfirm(value, formState.password),
                    autovalidateMode: formState.autovalidateMode,
                    onChanged: viewModel.setPasswordConfirm,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
