abstract final class Validators {
  Validators._();

  static const int minEmailLength = 6;
  static const int minPasswordLength = 8;
  static const int verificationCodeLength = 6;

  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
  );

  static final RegExp _passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d).{8,}$',
  );

  static final RegExp _verificationCodePattern = RegExp(r'^\d{6}$');

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!_emailPattern.hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (!_passwordPattern.hasMatch(value)) {
      return '영문, 숫자를 포함해 8자 이상 입력해주세요';
    }
    return null;
  }

  static String? passwordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (value != password) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  static String? verificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return '인증 코드 확인을 입력해주세요';
    }
    if (!_verificationCodePattern.hasMatch(value)) {
      return '6자리 숫자를 입력해주세요';
    }
    return null;
  }
}
