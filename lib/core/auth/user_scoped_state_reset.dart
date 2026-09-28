import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/auth/auth_session.dart';
import 'package:li_on/features/auth/presentation/view_models/login_view_model.dart';
import 'package:li_on/features/auth/presentation/view_models/sign_in_view_model.dart';
import 'package:li_on/features/calendar/data/calendar_repository.dart';
import 'package:li_on/features/calendar/presentation/view_models/calendar_view_model.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_recommendation_view_model.dart';
import 'package:li_on/features/certificate_search/presentation/view_models/certificate_search_view_model.dart';
import 'package:li_on/features/chat_history/data/chat_history_repository.dart';
import 'package:li_on/features/chat_history/presentation/view_models/chat_history_view_model.dart';
import 'package:li_on/features/data_room/data/data_room_repository.dart';
import 'package:li_on/features/data_room/presentation/view_models/data_room_view_model.dart';
import 'package:li_on/features/my/data/user_repository.dart';
import 'package:li_on/features/onboarding/presentation/view_models/onboarding_view_model.dart';
import 'package:li_on/features/roadmap_chat/presentation/view_models/roadmap_chat_view_model.dart';

/// 로그인 상태에서 로그아웃 상태로 바뀔 때마다 사용자별 캐시를 비운다.
///
/// 직접 로그아웃한 경우뿐 아니라 토큰 갱신에 실패해 세션이 만료된 경우
/// (AuthInterceptor → signOut)도 같은 길을 거치므로, 같은 기기에서 다른
/// 계정으로 로그인했을 때 이전 계정의 데이터가 보이지 않는다.
void resetUserScopedStateOnSignOut(ProviderContainer container) {
  final AuthSessionController authSession = container.read(authSessionProvider);
  bool wasAuthenticated = authSession.isAuthenticated;
  authSession.addListener(() {
    final bool isAuthenticated = authSession.isAuthenticated;
    if (wasAuthenticated && !isAuthenticated) _resetUserScopedState(container);
    wasAuthenticated = isAuthenticated;
  });
}

void _resetUserScopedState(ProviderContainer container) {
  container.invalidate(loginViewModelProvider);
  container.invalidate(signInViewModelProvider);
  container.invalidate(certificateSearchViewModelProvider);
  container.invalidate(certificateRecommendationsProvider);
  container.invalidate(myProfileProvider);
  container.invalidate(onboardingSelectionViewModelProvider);
  container.invalidate(onboardingSubmitViewModelProvider);
  container.invalidate(dataRoomFilterProvider);
  container.invalidate(dataRoomMaterialsProvider);
  container.invalidate(dataRoomRepositoryProvider);
  container.invalidate(calendarEventsProvider);
  container.invalidate(calendarEventRepositoryProvider);
  container.invalidate(chatHistoryViewModelProvider);
  container.invalidate(chatHistoriesProvider);
  container.invalidate(roadmapChatViewModelProvider);
}
