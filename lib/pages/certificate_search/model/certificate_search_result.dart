import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/pages/certificate_search/model/certificate.dart';

part 'certificate_search_result.g.dart';

/// `GET /api/certificates` 페이지네이션 응답.
/// 화면은 [content]만 쓰고 페이지 정보는 아직 안 써서, 서버의 페이지네이션
/// 응답 형태(필드명 등)가 예상과 달라도 목록 자체는 파싱되게 기본값을 둔다.
@JsonSerializable()
class CertificateSearchResult {
  final List<Certificate> content;

  @JsonKey(defaultValue: 0)
  final int page;

  @JsonKey(defaultValue: 0)
  final int totalElements;

  @JsonKey(defaultValue: 0)
  final int totalPages;

  const CertificateSearchResult({
    required this.content,
    this.page = 0,
    this.totalElements = 0,
    this.totalPages = 0,
  });

  factory CertificateSearchResult.fromJson(Map<String, dynamic> json) =>
      _$CertificateSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateSearchResultToJson(this);
}
