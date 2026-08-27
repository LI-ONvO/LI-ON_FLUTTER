import 'package:flutter/material.dart';
import 'package:li_on/core/utils/validators.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';

class EmailField extends StatelessWidget {
  final AutovalidateMode autovalidateMode;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final TextInputAction textInputAction;
  final TextEditingController? controller;

  const EmailField({
    super.key,
    required this.autovalidateMode,
    required this.onChanged,
    this.enabled = true,
    this.controller,
    // 이메일 뒤에는 보통 다음 입력창이 이어지므로 '다음'을 기본값으로 둔다.
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      key: const Key('emailField'),
      label: '이메일',
      hintText: 'example@email.com',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.email,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      enabled: enabled,
      textInputAction: textInputAction,
    );
  }
}
