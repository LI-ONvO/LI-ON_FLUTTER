/// 자료의 형태. 자료방 목록과 저장 시트에서 작은 배지로 노출된다.
enum MaterialResourceType { link, file, note }

extension MaterialResourceTypeLabel on MaterialResourceType {
  String get label => switch (this) {
    MaterialResourceType.link => '링크',
    MaterialResourceType.file => '파일',
    MaterialResourceType.note => '메모',
  };
}
