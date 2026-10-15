import 'package:li_on/features/certificate_search/data/certificate.dart';

/// 이름이 이보다 짧은 자격증은 일상 대화와 겹치기 쉬워 찾지 않는다.
const int _minNameLength = 3;

/// 국가기술자격. 같은 이름이 과정평가형 등으로도 내려올 때 우선한다.
const String _preferredQualGbCd = 'T';

String _normalize(String text) =>
    text.replaceAll(RegExp(r'\s+'), '').toLowerCase();

/// [text]에 이름이 언급된 자격증을 찾는다. 여러 개면 이름이 가장 긴 것을,
/// 이름이 같으면 국가기술자격을 고른다. 언급된 자격증이 없으면 null.
Certificate? findMentionedCertificate(
  String text,
  List<Certificate> certificates,
) {
  final String normalizedText = _normalize(text);
  Certificate? best;
  int bestLength = 0;
  for (final Certificate certificate in certificates) {
    final String name = _normalize(certificate.name);
    if (name.length < _minNameLength || !normalizedText.contains(name)) {
      continue;
    }
    final bool isBetter =
        name.length > bestLength ||
        (name.length == bestLength &&
            certificate.qualGbCd == _preferredQualGbCd &&
            best?.qualGbCd != _preferredQualGbCd);
    if (isBetter) {
      best = certificate;
      bestLength = name.length;
    }
  }
  return best;
}
