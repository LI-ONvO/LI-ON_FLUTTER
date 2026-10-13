import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/features/roadmap/data/roadmap_repository.dart';
import 'package:li_on/features/roadmap/data/roadmap_summary.dart';

/// 채팅 세션의 로드맵 스텝 목록. 아직 로드맵이 없으면 만든 뒤 다시 읽는다.
///
/// 로드맵 생성은 AI 응답을 기다려 오래 걸리고, 자동으로 다시 시도하면 같은
/// 세션에 로드맵이 중복 생성될 수 있어 재시도를 끈다. 시트를 닫아도 진행 중인
/// 생성이 이어지고 다시 열었을 때 결과를 그대로 쓰도록 autoDispose를 붙이지
/// 않았다.
final roadmapStepsProvider = FutureProvider.family<List<RoadmapSummary>, int>((
  ref,
  sessionId,
) async {
  final RoadmapRepository repository = ref.watch(roadmapRepositoryProvider);
  List<RoadmapSummary> steps = await repository.fetchRoadmaps(sessionId);
  if (steps.isEmpty) {
    await repository.createRoadmap(sessionId: sessionId);
    steps = await repository.fetchRoadmaps(sessionId);
  }
  return [...steps]..sort((a, b) => a.orderNo.compareTo(b.orderNo));
}, retry: (_, _) => null);
