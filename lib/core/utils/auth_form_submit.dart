import 'package:flutter/material.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';

Future<bool> submitAuthForm({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required VoidCallback onSubmitted,
  required Future<void> Function() onValid,
  required String successMessage,
  String failureMessage = '요청을 처리하지 못했어요',
  bool showSuccessMessage = true,
}) async {
  final bool isValid = formKey.currentState?.validate() ?? false;
  onSubmitted();

  if (!isValid) {
    CustomSnackbar.show(
      context,
      message: '입력 내용을 다시 확인해주세요',
      type: SnackbarType.error,
    );
    return false;
  }

  try {
    await onValid();
    if (!context.mounted) return true;
    if (showSuccessMessage) {
      CustomSnackbar.show(
        context,
        message: successMessage,
        type: SnackbarType.success,
      );
    }
    return true;
  } catch (error) {
    if (!context.mounted) return false;
    // 네트워크 계층이 만든 안내 문구가 있으면 그대로 보여준다.
    final String message = error is ApiException
        ? error.message
        : failureMessage;
    CustomSnackbar.show(context, message: message, type: SnackbarType.error);
    return false;
  }
}
