import 'package:json_annotation/json_annotation.dart';
import 'package:li_on/core/model/material_resource_type.dart';
import 'package:li_on/core/utils/json_converters.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';

export 'package:li_on/core/model/material_resource_type.dart';

part 'resource_response.g.dart';

/// `GET /api/resources` 목록의 자료 한 건.
@JsonSerializable()
class ResourceListItem {
  final int id;
  final String title;
  final String url;
  final MaterialResourceType type;
  final int? sessionId;
  final int? certificateId;
  @JsonKey(fromJson: localDateTimeFromJson)
  final DateTime createdAt;

  const ResourceListItem({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.sessionId,
    this.certificateId,
    required this.createdAt,
  });

  factory ResourceListItem.fromJson(Map<String, dynamic> json) =>
      _$ResourceListItemFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceListItemToJson(this);
}

@JsonSerializable()
class ResourcePageResult {
  final List<ResourceListItem> content;
  final int page;
  final int totalElements;
  final int totalPages;

  const ResourcePageResult({
    required this.content,
    required this.page,
    required this.totalElements,
    required this.totalPages,
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
  final MaterialResourceType type;
  final String memo;
  final ResourceSessionRef? session;
  final CertificateField? certificate;
  @JsonKey(fromJson: localDateTimeFromJson)
  final DateTime createdAt;

  const ResourceDetail({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    required this.memo,
    this.session,
    this.certificate,
    required this.createdAt,
  });

  factory ResourceDetail.fromJson(Map<String, dynamic> json) =>
      _$ResourceDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceDetailToJson(this);
}

/// `POST /api/resources` 응답.
@JsonSerializable()
class ResourceCreateResult {
  final int id;
  final String title;
  final String url;
  final MaterialResourceType type;
  @JsonKey(fromJson: localDateTimeFromJson)
  final DateTime createdAt;

  const ResourceCreateResult({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    required this.createdAt,
  });

  factory ResourceCreateResult.fromJson(Map<String, dynamic> json) =>
      _$ResourceCreateResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceCreateResultToJson(this);
}

/// `PATCH /api/resources/{resourceId}` 응답.
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
