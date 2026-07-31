import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/pages/certificate_search/provider/certificate_detail_view_model.dart';

/// 북마크 상태만 watch해서, 토글 시 상세 본문 전체가 다시 빌드되는 것을 막는다.
class CertificateBookmarkButton extends ConsumerWidget {
  final String certificateId;

  const CertificateBookmarkButton({super.key, required this.certificateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isBookmarked = ref.watch(
      certificateDetailViewModelProvider(
        certificateId,
      ).select((state) => state.isBookmarked),
    );

    return AppBarBookmarkButton(
      isBookmarked: isBookmarked,
      onTap: () => ref
          .read(certificateDetailViewModelProvider(certificateId).notifier)
          .toggleBookmark(),
    );
  }
}
