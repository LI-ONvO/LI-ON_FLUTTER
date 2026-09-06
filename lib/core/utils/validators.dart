abstract final class Validators {
  Validators._();

  static const int minEmailLength = 6;
  static const int minPasswordLength = 8;
  static const int verificationCodeLength = 6;
  static const int minNicknameLength = 2;
  static const int maxNicknameLength = 10;

  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
  );

  // 서버가 영문+숫자만으로는 "비밀번호 형식이 올바르지 않습니다"로
  // 거부하고, 특수문자를 포함해야 통과한다(실제 서버 응답으로 확인됨).
  static final RegExp _passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9\s]).{8,}$',
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
      return '영문, 숫자, 특수문자를 포함해 8자 이상 입력해주세요';
    }
    return null;
  }

  /// 로그인 화면에서 쓴다. 서버가 기준(형식)의 판단자이므로 여기서는
  /// 비어 있는지만 확인한다 — [password]의 형식 규칙을 로그인에도
  /// 적용하면, 규칙이 바뀌기 전에 만든 계정은 비밀번호가 맞아도 클라이언트
  /// 단계에서부터 로그인을 막아버릴 수 있다.
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    return null;
  }

  static String? nickname(String? value) {
    if (value == null || value.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    if (value.length < minNicknameLength || value.length > maxNicknameLength) {
      return '닉네임은 2~10자로 입력해주세요';
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
