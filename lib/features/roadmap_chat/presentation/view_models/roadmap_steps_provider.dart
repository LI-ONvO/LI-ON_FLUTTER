import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/features/roadmap/data/roadmap_detail.dart';
import 'package:li_on/features/roadmap/data/roadmap_repository.dart';
import 'package:li_on/features/roadmap/data/roadmap_summary.dart';

/// 채팅 세션의 로드맵 스텝 목록. 세션에 로드맵이 있으면 가장 최근 것의 스텝을
/// 읽고, 없으면 새로 만들어 생성 응답의 스텝을 그대로 쓴다.
///
/// 로드맵 생성은 AI 응답을 기다려 오래 걸리고, 자동으로 다시 시도하면 같은
/// 세션에 로드맵이 중복 생성될 수 있어 재시도를 끈다. 시트를 닫아도 진행 중인
/// 생성이 이어지고 다시 열었을 때 결과를 그대로 쓰도록 autoDispose를 붙이지
/// 않았다.
final roadmapStepsProvider = FutureProvider.family<List<RoadmapStep>, int>((
  ref,
  sessionId,
) async {
  final RoadmapRepository repository = ref.watch(roadmapRepositoryProvider);
  final List<RoadmapSummary> roadmaps = await repository.fetchRoadmaps(
    sessionId,
  );
  final RoadmapDetail detail;
  if (roadmaps.isEmpty) {
    detail = await repository.createRoadmap(sessionId: sessionId);
  } else {
    final RoadmapSummary latest = roadmaps.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
    detail = await repository.fetchRoadmapDetail(latest.id);
  }
  return [...detail.steps]..sort((a, b) => a.orderNo.compareTo(b.orderNo));
}, retry: (_, _) => null);
