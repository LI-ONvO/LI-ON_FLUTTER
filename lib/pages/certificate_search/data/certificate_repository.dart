import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/certificate_search/model/certificate.dart';

const List<Certificate> _dummyCertificates = [
  Certificate(id: '1', initial: '정', name: '정보처리기사', category: 'IT'),
  Certificate(id: '2', initial: 'S', name: 'SQLD', category: 'IT'),
  Certificate(id: '3', initial: '전', name: '전산회계 1급', category: '경영'),
  Certificate(id: '4', initial: '건', name: '건축기사', category: '건축'),
  Certificate(id: '5', initial: '간', name: '간호조무사', category: '보건'),
  Certificate(id: '6', initial: '평', name: '평생교육사', category: '교육'),
  Certificate(id: '7', initial: '네', name: '네트워크관리사', category: 'IT'),
  Certificate(id: '8', initial: '재', name: '재경관리사', category: '경영'),
];

/// 자격증 목록을 가져오는 방법을 추상화한다.
/// API 연동 시에는 이 인터페이스를 구현하는 클래스를 새로 만들고
/// [certificateRepositoryProvider]의 구현체만 교체하면 된다.
abstract class CertificateRepository {
  Future<List<Certificate>> fetchCertificates();
}

/// 실제 API가 준비되기 전까지 사용하는 더미 구현체.
class DummyCertificateRepository implements CertificateRepository {
  const DummyCertificateRepository();

  @override
  Future<List<Certificate>> fetchCertificates() async {
    return _dummyCertificates;
  }
}

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return const DummyCertificateRepository();
});

final certificatesProvider = FutureProvider<List<Certificate>>((ref) {
  return ref.watch(certificateRepositoryProvider).fetchCertificates();
});
