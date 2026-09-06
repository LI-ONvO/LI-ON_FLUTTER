import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/pages/certificate_search/model/certificate_detail.dart';
import 'package:li_on/pages/certificate_search/provider/certificate_repository.dart';
import 'package:li_on/pages/certificate_search/widget/bookmark_button.dart';
import 'package:li_on/pages/certificate_search/widget/detail_body.dart';

class CertificateDetailPage extends ConsumerWidget {
  final String certificateId;

  /// 목록 화면에서 이미 알고 있는 자격증 이름. 상세 데이터가 로딩되는 동안
  /// AppBar 제목이 비어 보이지 않도록 임시로 사용한다.
  final String? initialTitle;

  const CertificateDetailPage({
    super.key,
    required this.certificateId,
    this.initialTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CertificateDetail?> detailAsync = ref.watch(
      certificateDetailProvider(certificateId),
    );
    // 상세 데이터가 로딩 중이어도 목록에서 넘겨받은 이름으로 로드맵을 열 수
    // 있도록, 둘 중 먼저 확보되는 이름을 사용한다.
    final String certificateName =
        detailAsync.value?.name ?? initialTitle ?? '';

    return BaseScaffold(
      appBar: CustomAppBar(
        title: certificateName,
        actions: [CertificateBookmarkButton(certificateId: certificateId)],
      ),
      bottomBar: CustomElevatedButton(
        text: '로드맵 만들기',
        backgroundColor: AppColors.primary,
        onPressed: () {
          if (certificateName.isEmpty) return;
          if (ModalRoute.of(context)?.isCurrent != true) return;
          context.push('/roadmap/chat/${Uri.encodeComponent(certificateName)}');
        },
      ),
      child: detailAsync.when(
        data: (detail) => detail == null
            ? Center(
                child: Text('자격증 정보를 찾을 수 없어요', style: AppTextStyle.subText),
              )
            : CertificateDetailBody(detail: detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('정보를 불러오지 못했어요', style: AppTextStyle.subText)),
      ),
    );
  }
}
