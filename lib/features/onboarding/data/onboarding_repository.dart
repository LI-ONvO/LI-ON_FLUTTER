import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/onboarding/data/onboarding_question.dart';
import 'package:li_on/features/onboarding/data/onboarding_submit_result.dart';

/// 온보딩 설문 답변 한 건. 선택한 선택지들의 `value`를 [optionValues]에 담는다.
class OnboardingAnswer {
  final String questionKey;
  final List<String> optionValues;

  const OnboardingAnswer({
    required this.questionKey,
    this.optionValues = const [],
  });

  Map<String, dynamic> toJson() => {
    'questionKey': questionKey,
    'optionValues': optionValues,
  };
}

/// 온보딩 질문 조회·답변 제출을 추상화한다.
abstract class OnboardingRepository {
  /// `GET /api/onboarding/questions` — 동적 질문 목록.
  Future<List<OnboardingQuestion>> fetchQuestions();

  /// `POST /api/users/me/onboarding` — 설문 답변 제출.
  Future<OnboardingSubmitResult> submitAnswers(List<OnboardingAnswer> answers);
}

class HttpOnboardingRepository implements OnboardingRepository {
  HttpOnboardingRepository(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<List<OnboardingQuestion>> fetchQuestions() {
    return guardApiCall(() async {
      final response = await apiClient.dio.get('/api/onboarding/questions');
      return (response.data as List)
          .map(
            (json) => OnboardingQuestion.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    });
  }

  @override
  Future<OnboardingSubmitResult> submitAnswers(
    List<OnboardingAnswer> answers,
  ) {
    return guardApiCall(() async {
      final response = await apiClient.dio.post(
        '/api/users/me/onboarding',
        data: {'answers': answers.map((answer) => answer.toJson()).toList()},
      );
      return OnboardingSubmitResult.fromJson(response.data);
    });
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return HttpOnboardingRepository(ref.watch(apiClientProvider));
});

/// 온보딩 화면에 표시할 동적 질문 목록.
final onboardingQuestionsProvider = FutureProvider<List<OnboardingQuestion>>((
  ref,
) {
  return ref.watch(onboardingRepositoryProvider).fetchQuestions();
});
