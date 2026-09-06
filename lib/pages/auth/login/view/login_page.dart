import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/utils/auth_form_submit.dart';
import 'package:li_on/core/utils/validators.dart';
import 'package:li_on/core/widgets/auth_header/auth_header.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';
import 'package:li_on/core/widgets/text_field/email_field.dart';
import 'package:li_on/pages/auth/login/provider/login_view_model.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final LoginViewModel viewModel = ref.read(loginViewModelProvider.notifier);
    final bool isValid = await submitAuthForm(
      context: context,
      formKey: _formKey,
      onSubmitted: viewModel.markSubmitted,
      successMessage: '로그인되었습니다',
      showSuccessMessage: false,
      onValid: viewModel.login,
    );
    if (!mounted) return;
    if (isValid) _goToLogin();
  }

  void _goToLogin() {
    context.go('/search');
  }

  void _goToSignUp() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    ref.read(loginViewModelProvider.notifier).reset();
    context.push('/sign-up');
  }

  @override
  Widget build(BuildContext context) {
    final LoginState formState = ref.watch(loginViewModelProvider);
    final LoginViewModel viewModel = ref.read(loginViewModelProvider.notifier);

    return BaseScaffold(
      appBar: null,
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomElevatedButton(
            onPressed: formState.isFilled && !formState.isSubmitting
                ? _submit
                : null,
            text: '로그인',
            backgroundColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.space3),
          GestureDetector(
            onTap: _goToSignUp,
            child: Text(
              '회원가입',
              style: AppTextStyle.mainText.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: AuthHeader()),
                    const SizedBox(height: AppSpacing.space6),
                    Column(
                      spacing: AppSpacing.space2,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EmailField(
                          controller: _emailController,
                          autovalidateMode: formState.autovalidateMode,
                          onChanged: viewModel.setEmail,
                        ),
                        CustomTextField(
                          key: const Key('passwordField'),
                          label: '비밀번호',
                          hintText: '비밀번호를 입력해주세요',
                          controller: _passwordController,
                          obscureText: true,
                          validator: Validators.requiredPassword,
                          autovalidateMode: formState.autovalidateMode,
                          onChanged: viewModel.setPassword,
                          textInputAction: TextInputAction.done,
                          // 키보드의 완료 버튼으로도 바로 로그인할 수 있게 한다.
                          // 요청이 진행 중일 때는 무시해, 첫 요청이 끝나기 전에
                          // 성공으로 오인해 화면이 넘어가는 일을 막는다.
                          onSubmitted: (_) {
                            if (formState.isFilled && !formState.isSubmitting) {
                              _submit();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
