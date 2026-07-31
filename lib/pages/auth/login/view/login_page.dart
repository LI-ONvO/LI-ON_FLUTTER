import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:li_on/pages/auth/sign_in/view/sign_in_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submit() {
    final LoginViewModel viewModel = ref.read(loginViewModelProvider.notifier);
    submitAuthForm(
      context: context,
      formKey: _formKey,
      onSubmitted: viewModel.markSubmitted,
      successMessage: '로그인되었습니다',
    );
  }

  void _goToSignUp() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (context) => const SignInPage()));
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
            onPressed: formState.isFilled ? _submit : null,
            text: '로그인',
            backgroundColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.space1),
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
                          autovalidateMode: formState.autovalidateMode,
                          onChanged: viewModel.setEmail,
                        ),
                        CustomTextField(
                          key: const Key('passwordField'),
                          label: '비밀번호',
                          hintText: '비밀번호 입력',
                          obscureText: true,
                          validator: Validators.password,
                          autovalidateMode: formState.autovalidateMode,
                          onChanged: viewModel.setPassword,
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
