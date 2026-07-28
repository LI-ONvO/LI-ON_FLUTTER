import 'package:flutter/widgets.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';

/// Validates [formKey], calls [onSubmitted] to record the attempt, then shows
/// [successMessage] on success or a generic retry message on failure.
void submitAuthForm({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required VoidCallback onSubmitted,
  required String successMessage,
}) {
  final bool isValid = formKey.currentState?.validate() ?? false;
  onSubmitted();
  CustomSnackbar.show(
    context,
    message: isValid ? successMessage : '입력 내용을 다시 확인해주세요',
    type: isValid ? SnackbarType.success : SnackbarType.error,
  );
}
