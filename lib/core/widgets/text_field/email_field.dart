import 'package:flutter/material.dart';
import 'package:li_on/core/utils/validators.dart';
import 'package:li_on/core/widgets/text_field/custom_text_field.dart';

class EmailField extends StatelessWidget {
  final AutovalidateMode autovalidateMode;
  final ValueChanged<String> onChanged;

  const EmailField({
    super.key,
    required this.autovalidateMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      key: const Key('emailField'),
      label: '이메일',
      hintText: 'you@example.com',
      keyboardType: TextInputType.emailAddress,
      validator: Validators.email,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
    );
  }
}
