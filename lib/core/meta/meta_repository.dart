import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/model/job_field.dart';
import 'package:li_on/core/network/api_client.dart';
import 'package:li_on/core/network/api_exception.dart';

/// 직무·희망 분야 마스터 목록을 가져오는 방법을 추상화한다.
abstract class MetaRepository {
  /// `GET /api/jobs` — 직무 목록.
  Future<List<JobField>> fetchJobs();

  /// `GET /api/fields` — 희망 분야 목록.
  Future<List<JobField>> fetchFields();
}

class HttpMetaRepository implements MetaRepository {
  HttpMetaRepository(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<List<JobField>> fetchJobs() {
    return guardApiCall(() async {
      final response = await apiClient.dio.get('/api/jobs');
      return (response.data as List)
          .map((json) => JobField.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<List<JobField>> fetchFields() {
    return guardApiCall(() async {
      final response = await apiClient.dio.get('/api/fields');
      return (response.data as List)
          .map((json) => JobField.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }
}

final metaRepositoryProvider = Provider<MetaRepository>((ref) {
  return HttpMetaRepository(ref.watch(apiClientProvider));
});

/// 서버에 등록된 직무 목록.
final jobsProvider = FutureProvider<List<JobField>>((ref) {
  return ref.watch(metaRepositoryProvider).fetchJobs();
});

/// 서버에 등록된 희망 분야 목록.
final fieldsProvider = FutureProvider<List<JobField>>((ref) {
  return ref.watch(metaRepositoryProvider).fetchFields();
});
