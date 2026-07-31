import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/pages/certificate_search/model/certificate.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';

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

/// 자격증 상세 더미 데이터.
/// key는 [_dummyCertificates]의 [Certificate.id]와 매칭된다.
const Map<String, CertificateDetail> _dummyCertificateDetails = {
  '1': CertificateDetail(
    id: 101,
    name: '정보처리기사',
    issuingOrg: '한국산업인력공단',
    category: 'IT',
    description: '정보시스템의 개발과 운영에 필요한 실무 지식을 검증하는 국가기술자격증입니다.',
    examInfo: '필기 5과목 / 실기 1과목, 연 3회 시행',
    fields: [CertificateField(id: 5, name: '보안')],
    level: '중급',
    examFee: '19,400원',
    passRate: 42.3,
    examDuration: '필기 2시간 30분',
    subjects: [
      ExamSubject(name: '소프트웨어 설계', percent: 0.22),
      ExamSubject(name: '소프트웨어 개발', percent: 0.20),
      ExamSubject(name: '데이터베이스 구축', percent: 0.20),
      ExamSubject(name: '프로그래밍 언어 활용', percent: 0.20),
      ExamSubject(name: '정보시스템 구축관리', percent: 0.18),
    ],
  ),
  '2': CertificateDetail(
    id: 102,
    name: 'SQLD',
    issuingOrg: '한국데이터산업진흥원',
    category: 'IT',
    description: '데이터 모델링과 SQL 활용 능력을 검증하는 민간자격증입니다.',
    examInfo: '필기 2과목, 연 4회 시행',
    fields: [CertificateField(id: 6, name: '데이터')],
    level: '초급',
    examFee: '50,000원',
    passRate: 58.6,
    examDuration: '필기 1시간 30분',
    subjects: [
      ExamSubject(name: '데이터 모델링의 이해', percent: 0.40),
      ExamSubject(name: 'SQL 기본 및 활용', percent: 0.60),
    ],
  ),
  '3': CertificateDetail(
    id: 103,
    name: '전산회계 1급',
    issuingOrg: '한국세무사회',
    category: '경영',
    description: '전산 회계 프로그램을 활용한 실무 회계 처리 능력을 평가하는 자격증입니다.',
    examInfo: '이론 + 실무, 연 6회 시행',
    fields: [CertificateField(id: 2, name: '회계')],
    level: '초급',
    examFee: '30,000원',
    passRate: 63.1,
    examDuration: '60분',
    subjects: [
      ExamSubject(name: '이론', percent: 0.30),
      ExamSubject(name: '실무', percent: 0.70),
    ],
  ),
  '4': CertificateDetail(
    id: 104,
    name: '건축기사',
    issuingOrg: '한국산업인력공단',
    category: '건축',
    description: '건축물의 설계·시공·감리 실무 능력을 검증하는 국가기술자격증입니다.',
    examInfo: '필기 5과목 / 실기 1과목, 연 3회 시행',
    fields: [CertificateField(id: 3, name: '건축')],
    level: '중급',
    examFee: '19,400원',
    passRate: 35.7,
    examDuration: '필기 2시간 30분',
    subjects: [
      ExamSubject(name: '건축계획', percent: 0.20),
      ExamSubject(name: '건축시공', percent: 0.20),
      ExamSubject(name: '건축구조', percent: 0.20),
      ExamSubject(name: '건축설비', percent: 0.20),
      ExamSubject(name: '건축법규', percent: 0.20),
    ],
  ),
  '5': CertificateDetail(
    id: 105,
    name: '간호조무사',
    issuingOrg: '한국보건의료인국가시험원',
    category: '보건',
    description: '의료기관에서 간호 보조 업무를 수행하는 국가자격증입니다.',
    examInfo: '필기시험, 연 1회 시행',
    fields: [CertificateField(id: 4, name: '의료')],
    level: '초급',
    examFee: '90,000원',
    passRate: 88.7,
    examDuration: '2시간 30분',
    subjects: [
      ExamSubject(name: '기초간호학', percent: 0.40),
      ExamSubject(name: '보건간호학', percent: 0.30),
      ExamSubject(name: '공중보건학개론', percent: 0.30),
    ],
  ),
  '6': CertificateDetail(
    id: 106,
    name: '평생교육사',
    issuingOrg: '국가평생교육진흥원',
    category: '교육',
    description: '평생교육 프로그램의 기획·운영·평가를 담당하는 전문가 자격증입니다.',
    examInfo: '자격연수 이수, 연 1회 접수',
    fields: [CertificateField(id: 1, name: '교육')],
    level: '중급',
    examFee: '150,000원',
    passRate: 76.4,
    examDuration: '과목별 상이',
    subjects: [
      ExamSubject(name: '평생교육방법론', percent: 0.30),
      ExamSubject(name: '평생교육프로그램개발론', percent: 0.35),
      ExamSubject(name: '평생교육경영론', percent: 0.35),
    ],
  ),
  '7': CertificateDetail(
    id: 107,
    name: '네트워크관리사',
    issuingOrg: '한국정보통신자격협회',
    category: 'IT',
    description: '네트워크 설계·구축·운영 관리 능력을 검증하는 민간자격증입니다.',
    examInfo: '필기 + 실기, 연 4회 시행',
    fields: [CertificateField(id: 5, name: '보안')],
    level: '중급',
    examFee: '40,000원',
    passRate: 45.2,
    examDuration: '필기 1시간 30분',
    subjects: [
      ExamSubject(name: 'TCP/IP', percent: 0.35),
      ExamSubject(name: '네트워크 일반', percent: 0.35),
      ExamSubject(name: 'NOS', percent: 0.30),
    ],
  ),
  '8': CertificateDetail(
    id: 108,
    name: '재경관리사',
    issuingOrg: '삼일회계법인',
    category: '경영',
    description: '재무회계·세무회계·원가관리회계 실무 능력을 평가하는 민간자격증입니다.',
    examInfo: '객관식, 연 8회 시행',
    fields: [CertificateField(id: 2, name: '회계')],
    level: '중급',
    examFee: '73,000원',
    passRate: 30.5,
    examDuration: '80분',
    subjects: [
      ExamSubject(name: '재무회계', percent: 0.40),
      ExamSubject(name: '세무회계', percent: 0.30),
      ExamSubject(name: '원가관리회계', percent: 0.30),
    ],
  ),
};

/// 자격증 목록을 가져오는 방법을 추상화한다.
/// API 연동 시에는 이 인터페이스를 구현하는 클래스를 새로 만들고
/// [certificateRepositoryProvider]의 구현체만 교체하면 된다.
abstract class CertificateRepository {
  Future<List<Certificate>> fetchCertificates();
  Future<CertificateDetail?> fetchCertificateDetail(String id);
}

/// 실제 API가 준비되기 전까지 사용하는 더미 구현체.
class DummyCertificateRepository implements CertificateRepository {
  const DummyCertificateRepository();

  @override
  Future<List<Certificate>> fetchCertificates() async {
    return _dummyCertificates;
  }

  @override
  Future<CertificateDetail?> fetchCertificateDetail(String id) async {
    return _dummyCertificateDetails[id];
  }
}

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return const DummyCertificateRepository();
});

final certificatesProvider = FutureProvider<List<Certificate>>((ref) {
  return ref.watch(certificateRepositoryProvider).fetchCertificates();
});

/// 자격증 상세 정보.
/// [id]는 [Certificate.id]와 매칭되는 문자열 키다.
final certificateDetailProvider = FutureProvider.autoDispose
    .family<CertificateDetail?, String>((ref, id) {
      return ref
          .watch(certificateRepositoryProvider)
          .fetchCertificateDetail(id);
    });
