import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:li_on/pages/auth/sign_in/view_model/sign_in_view_model.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submit() {
    final SignInViewModel viewModel = ref.read(signInViewModelProvider.notifier);
    submitAuthForm(
      context: context,
      formKey: _formKey,
      onSubmitted: viewModel.markSubmitted,
      successMessage: '인증 메일을 보냈습니다',
    );
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
        onPressed: formState.isFilled ? _submit : null,
        text: '메일 인증 받기',
        backgroundColor: AppColors.primary,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(),
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
                    hintText: '8자 이상 입력해주세요',
                    obscureText: true,
                    validator: Validators.password,
                    autovalidateMode: formState.autovalidateMode,
                    onChanged: viewModel.setPassword,
                  ),
                  CustomTextField(
                    key: const Key('passwordConfirmField'),
                    label: '비밀번호 확인',
                    hintText: '비밀번호를 다시 입력해주세요',
                    obscureText: true,
                    validator: (value) =>
                        Validators.passwordConfirm(value, formState.password),
                    autovalidateMode: formState.autovalidateMode,
                    onChanged: viewModel.setPasswordConfirm,
                  ),
                  CustomTextField(
                    key: const Key('verificationCodeField'),
                    label: '인증 코드 확인',
                    hintText: '인증 코드를 입력해주세요',
                    keyboardType: TextInputType.number,
                    validator: Validators.verificationCode,
                    autovalidateMode: formState.autovalidateMode,
                    onChanged: viewModel.setVerificationCode,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
