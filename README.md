# LI-ON

대덕소프트웨어마이스터고등학교 학생을 위한 자격증 AI 학습 로드맵 Flutter 앱입니다. 자격증 탐색부터 학습 로드맵, 일정, 자료를 한곳에서 관리할 수 있도록 구성했습니다.

## 주요 기능

| 영역 | 제공 기능 |
| --- | --- |
| 인증 | 로그인, 회원가입, 이메일 인증, 입력값 검증 |
| 자격증 탐색 | 키워드·카테고리 검색, 자격증 상세 정보, 북마크 |
| 로드맵 | AI 로드맵 대화 UI, 대화 내역, 학습 일정을 캘린더에 추가 |
| 자료방 | 자료 목록·필터, 상세 보기, 수정·삭제 |
| 캘린더 | 월간·주간 보기, 일정 생성·수정·삭제, 알림과 연결 자격증 설정 |
| 프로필 | 기본 정보와 희망 분야 편집, 로그아웃 |

## 기술 스택

- **Framework:** Flutter, Dart `^3.12.1`
- **State management:** Riverpod
- **Routing:** GoRouter의 5탭 `StatefulShellRoute`
- **Networking:** Dio, `flutter_secure_storage`
- **Serialization:** `json_serializable`, `build_runner`
- **UI:** Material Design, `flutter_svg`, HelveticaNeue 폰트

## 시작하기

### 요구 사항

- Flutter stable SDK
- Dart SDK `^3.12.1`
- iOS 빌드는 macOS와 Xcode, Android 빌드는 Android SDK 필요

### 설치 및 실행

```bash
git clone https://github.com/LI-ONvO/LI-ON_FLUTTER.git
cd LI-ON_FLUTTER
cp .env.example .env
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### 검증

```bash
flutter analyze
flutter test
```

### API 서버 연결하기

모든 저장소는 실제 서버(`Http*Repository`)와 통신합니다. 서버 주소는 프로젝트
루트의 `.env` 파일(`.env.example`을 복사해서 생성, git에는 커밋하지 않음)의
`API_BASE_URL` 값을 읽으며, 지정하지 않으면 `http://localhost:8080`을 씁니다.

```env
API_BASE_URL=https://api.example.com
```

`.env`를 고치고 `flutter run`(핫 리스타트 `R`)만 하면 바로 반영됩니다.

CI는 Codemagic에서 의존성 설치, 모델 코드 생성, 정적 분석, 테스트, Android debug APK 및 iOS debug 빌드를 수행합니다.

## 프로젝트 구조

```text
lib/
├── core/
│   ├── constants/       # 색상, 폰트, 간격, 공통 상수
│   ├── network/         # Dio 클라이언트, 인증 인터셉터, 토큰 저장소
│   ├── router/          # GoRouter와 하단 탭 셸
│   ├── utils/           # 폼 검증과 제출 보조 로직
│   └── widgets/         # 공통 UI 컴포넌트
├── pages/
│   ├── auth/            # 로그인, 회원가입, 이메일 인증
│   ├── calendar/        # 캘린더와 일정
│   ├── certificate_search/
│   ├── data_room/       # 학습 자료 관리
│   ├── my/              # 프로필
│   ├── onboarding/
│   └── roadmap/         # 로드맵 대화, 대화 내역, 자료 저장
└── main.dart
```

기능은 주로 `model`, `provider`, `view`, `widget` 계층으로 나뉩니다. 상태와 의존성은 Riverpod provider로 연결하며, 데이터 저장소는 각 기능의 repository를 통해 접근합니다.

## 화면 흐름

앱은 스플래시 화면 뒤 로그인 화면으로 이동합니다. 로그인 이후에는 아래 다섯 탭을 공유하는 하단 내비게이션을 사용합니다.

1. 탐색
2. 로드맵
3. 자료방
4. 캘린더
5. 프로필

자격증·자료 상세, 대화 내역, 인증 화면은 하단 탭 없이 전체 화면으로 열립니다.

## 데이터 및 API 상태

모든 화면이 `Http*Repository`를 통해 실제 서버 API를 호출합니다. API 서버 주소는
`lib/core/network/api_client.dart`의 `apiClientProvider`가 `.env`의
`API_BASE_URL` 값(기본값 `http://localhost:8080`)을 사용합니다.

## 생성 파일

`json_serializable` 모델의 `*.g.dart` 파일은 Git에 포함하지 않습니다. 모델을 변경한 뒤 아래 명령으로 생성합니다.

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 테스트

위젯·provider 테스트는 `test/` 디렉터리에 있습니다. 회원가입 검증, 온보딩, 자료방 CRUD 및 링크, 로드맵 자료 저장 흐름을 다룹니다.

구체적인 수동 QA 결과는 [QA_NOTES.md](QA_NOTES.md)를 참고하세요.
