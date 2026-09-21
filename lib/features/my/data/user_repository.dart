import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/features/my/data/desired_fields_update_result.dart';
import 'package:li_on/features/my/data/info_edit.dart';
import 'package:li_on/features/my/data/profile.dart';

/// 내 계정 정보를 읽고 고치는 방법을 추상화한다.
abstract class UserRepository {
  /// `GET /api/users/me` — 내 프로필 조회.
  Future<Profile> fetchMyProfile();

  /// `PATCH /api/users/me` — 닉네임·직무 부분 수정.
  Future<InfoEditResponse> updateInfo(InfoEditRequest request);

  /// `PUT /api/users/me/desired-fields` — 희망 분야 전체 교체.
  Future<DesiredFieldsUpdateResult> updateDesiredFields(
    List<int> desiredFieldIds,
  );
}

class HttpUserRepository implements UserRepository {
  HttpUserRepository(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<Profile> fetchMyProfile() {
    return guardApiCall(() async {
      final response = await apiClient.dio.get('/api/users/me');
      return Profile.fromJson(response.data);
    });
  }

  @override
  Future<InfoEditResponse> updateInfo(InfoEditRequest request) {
    return guardApiCall(() async {
      final response = await apiClient.dio.patch(
        '/api/users/me',
        data: request.toJson(),
      );
      return InfoEditResponse.fromJson(response.data);
    });
  }

  @override
  Future<DesiredFieldsUpdateResult> updateDesiredFields(
    List<int> desiredFieldIds,
  ) {
    return guardApiCall(() async {
      final response = await apiClient.dio.put(
        '/api/users/me/desired-fields',
        data: {'desiredFieldIds': desiredFieldIds},
      );
      return DesiredFieldsUpdateResult.fromJson(response.data);
    });
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return HttpUserRepository(ref.watch(apiClientProvider));
});

/// 내 프로필. 수정 후에는 `ref.invalidate(myProfileProvider)`로 갱신한다.
final myProfileProvider = FutureProvider<Profile>((ref) {
  return ref.watch(userRepositoryProvider).fetchMyProfile();
});
