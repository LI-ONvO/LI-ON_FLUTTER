import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/material_resource_type.dart';
import 'package:li_on/core/utils/json_converters.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';

export 'package:li_on/core/model/material_resource_type.dart';

part 'resource_response.g.dart';

/// `GET /api/resources` 목록의 자료 한 건.
/// 명세서 기준: `{ id, title, url, memo, sessionId, jmCd, createdAt }`.
@JsonSerializable()
class ResourceListItem {
  final int id;
  final String title;
  final String url;

  @JsonKey(defaultValue: '')
  final String memo;

  final int? sessionId;
  final String? jmCd;

  @JsonKey(fromJson: localDateTimeFromJson)
  final DateTime createdAt;

  const ResourceListItem({
    required this.id,
    required this.title,
    required this.url,
    this.memo = '',
    this.sessionId,
    this.jmCd,
    required this.createdAt,
  });

  factory ResourceListItem.fromJson(Map<String, dynamic> json) =>
      _$ResourceListItemFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceListItemToJson(this);
}

/// 화면은 [content]만 쓰고 페이지 정보는 아직 안 써서, 서버의 페이지네이션
/// 응답 형태(필드명 등)가 예상과 달라도 목록 자체는 파싱되게 기본값을 둔다.
@JsonSerializable()
class ResourcePageResult {
  final List<ResourceListItem> content;

  @JsonKey(defaultValue: 0)
  final int page;

  @JsonKey(defaultValue: 0)
  final int totalElements;

  @JsonKey(defaultValue: 0)
  final int totalPages;

  const ResourcePageResult({
    required this.content,
    this.page = 0,
    this.totalElements = 0,
    this.totalPages = 0,
  });

  factory ResourcePageResult.fromJson(Map<String, dynamic> json) =>
      _$ResourcePageResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResourcePageResultToJson(this);
}

/// 자료 상세보기 응답 안의 출처 세션 요약(`{ id, title }`).
@JsonSerializable()
class ResourceSessionRef {
  final int id;
  final String title;

  const ResourceSessionRef({required this.id, required this.title});

  factory ResourceSessionRef.fromJson(Map<String, dynamic> json) =>
      _$ResourceSessionRefFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceSessionRefToJson(this);
}

/// `GET /api/resources/{resourceId}` 응답.
@JsonSerializable()
class ResourceDetail {
  final int id;
  final String title;
  final String url;

  @JsonKey(defaultValue: '')
  final String memo;

  final MaterialResourceType type;
  final ResourceSessionRef? session;
  final CertificateRef? certificate;

  @JsonKey(fromJson: localDateTimeFromJson)
  final DateTime createdAt;

  const ResourceDetail({
    required this.id,
    required this.title,
    required this.url,
    this.memo = '',
    required this.type,
    this.session,
    this.certificate,
    required this.createdAt,
  });

  factory ResourceDetail.fromJson(Map<String, dynamic> json) =>
      _$ResourceDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceDetailToJson(this);
}

/// `POST /api/resources` 응답.
/// 명세서 기준: `{ id, title, url, memo, sessionId, jmCd, createdAt }`.
@JsonSerializable()
class ResourceCreateResult {
  final int id;
  final String title;
  final String url;

  @JsonKey(defaultValue: '')
  final String memo;

  final int? sessionId;
  final String? jmCd;

  @JsonKey(fromJson: localDateTimeFromJson)
  final DateTime createdAt;

  const ResourceCreateResult({
    required this.id,
    required this.title,
    required this.url,
    this.memo = '',
    this.sessionId,
    this.jmCd,
    required this.createdAt,
  });

  factory ResourceCreateResult.fromJson(Map<String, dynamic> json) =>
      _$ResourceCreateResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceCreateResultToJson(this);
}

/// `PATCH /api/resources/{resourceId}` 응답: `{ id, title, memo }`.
@JsonSerializable()
class ResourceUpdateResult {
  final int id;
  final String title;
  final String memo;

  const ResourceUpdateResult({
    required this.id,
    required this.title,
    required this.memo,
  });

  factory ResourceUpdateResult.fromJson(Map<String, dynamic> json) =>
      _$ResourceUpdateResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceUpdateResultToJson(this);
}
