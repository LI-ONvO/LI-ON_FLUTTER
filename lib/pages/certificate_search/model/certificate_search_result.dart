import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/pages/certificate_search/model/certificate.dart';

part 'certificate_search_result.g.dart';

/// `GET /api/certificates` 페이지네이션 응답.
@JsonSerializable()
class CertificateSearchResult {
  final List<Certificate> content;
  final int page;
  final int totalElements;
  final int totalPages;

  const CertificateSearchResult({
    required this.content,
    required this.page,
    required this.totalElements,
    required this.totalPages,
  });

  factory CertificateSearchResult.fromJson(Map<String, dynamic> json) =>
      _$CertificateSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateSearchResultToJson(this);
}
