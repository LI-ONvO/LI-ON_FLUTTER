import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/network/api_exception.dart';
import 'package:li_on/core/widgets/app_bar/custom_app_bar.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';
import 'package:li_on/core/widgets/layout/base_scaffold.dart';
import 'package:li_on/core/widgets/progress/custom_progress_indicator.dart';
import 'package:li_on/core/widgets/snackbar/custom_snackbar.dart';
import 'package:li_on/features/certificate_search/data/certificate.dart';
import 'package:li_on/features/certificate_search/data/certificate_detail.dart';
import 'package:li_on/features/certificate_search/data/certificate_repository.dart';
import 'package:li_on/features/certificate_search/presentation/widgets/bookmark_button.dart';
import 'package:li_on/features/certificate_search/presentation/widgets/detail_body.dart';
import 'package:li_on/features/roadmap/data/roadmap_repository.dart';

class CertificateDetailPage extends ConsumerWidget {
  final String certificateId;

  /// 목록 화면에서 이미 알고 있는 자격증 이름. 상세 데이터가 로딩되는 동안
  /// AppBar 제목이 비어 보이지 않도록 임시로 사용한다.
  final String? initialTitle;

  /// 있으면 "로드맵 만들기" 대신, 이 채팅 세션에 자격증을 연결하는 버튼을 보여준다.
  final int? selectForSessionId;

  const CertificateDetailPage({
    super.key,
    required this.certificateId,
    this.initialTitle,
    this.selectForSessionId,
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
      bottomBar: selectForSessionId != null
          ? _SelectCertificateButton(
              sessionId: selectForSessionId!,
              certificateId: certificateId,
              certificateName: certificateName,
            )
          : CustomElevatedButton(
              text: '로드맵 만들기',
              backgroundColor: AppColors.primary,
              onPressed: () {
                if (certificateName.isEmpty) return;
                if (ModalRoute.of(context)?.isCurrent != true) return;
                context.push(
                  '/roadmap/chat/${Uri.encodeComponent(certificateName)}'
                  '?jmCd=${Uri.encodeComponent(certificateId)}',
                );
              },
            ),
      child: detailAsync.when(
        data: (detail) => detail == null || !detail.hasContent
            ? Center(child: Text('자격증 상세 내용이 없어요', style: AppTextStyle.subText))
            : CertificateDetailBody(detail: detail),
        loading: () => const CustomProgressIndicator(),
        error: (error, stackTrace) =>
            Center(child: Text('정보를 불러오지 못했어요', style: AppTextStyle.subText)),
      ),
    );
  }
}

/// 자격증 선택 실패를 안내 문구로 바꾼다.
String _selectFailureMessage(Object error) {
  if (error is ApiException) {
    if (error.code == 'CERTIFICATE_ALREADY_EXISTS') {
      return '이미 자격증이 선택된 대화예요';
    }
    return error.message;
  }
  return '자격증을 선택하지 못했어요. 잠시 후 다시 시도해주세요.';
}

/// 채팅 세션에 이 자격증을 연결하고, 연결한 자격증을 결과로 돌려주며 닫는다.
class _SelectCertificateButton extends ConsumerStatefulWidget {
  const _SelectCertificateButton({
    required this.sessionId,
    required this.certificateId,
    required this.certificateName,
  });

  final int sessionId;
  final String certificateId;
  final String certificateName;

  @override
  ConsumerState<_SelectCertificateButton> createState() =>
      _SelectCertificateButtonState();
}

class _SelectCertificateButtonState
    extends ConsumerState<_SelectCertificateButton> {
  bool _isSubmitting = false;

  Future<void> _select() async {
    if (widget.certificateName.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(roadmapRepositoryProvider)
          .selectSessionCertificate(
            sessionId: widget.sessionId,
            jmCd: widget.certificateId,
          );
      if (!mounted) return;
      context.pop(
        CertificateRef(
          jmCd: widget.certificateId,
          name: widget.certificateName,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      CustomSnackbar.show(
        context,
        message: _selectFailureMessage(error),
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      text: '자격증 선택하기',
      backgroundColor: AppColors.primary,
      onPressed: _isSubmitting ? null : _select,
    );
  }
}
