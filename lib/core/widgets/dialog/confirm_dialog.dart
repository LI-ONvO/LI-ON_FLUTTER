import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/core/widgets/button/custom_elevated_button.dart';

/// 좁은 화면에서도 좌우 여백이 남도록 제한한다.
const double _maxDialogWidth = 300;

/// 되돌릴 수 없는 동작을 한 번 더 확인받는 다이얼로그.
class ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;

  /// 확인 버튼을 위험한 동작(삭제 등)으로 보이게 한다.
  final bool destructive;

  const ConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.confirmText,
    this.cancelText = '취소',
    this.destructive = true,
  });

  /// 다이얼로그를 띄우고, 사용자가 확인을 누르면 true를 돌려준다.
  /// 취소하거나 바깥을 눌러 닫으면 false.
  static Future<bool> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String confirmText,
    String cancelText = '취소',
    bool destructive = true,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      // 셸 브랜치의 중첩 Navigator가 아니라 최상위에 띄워 화면 전체를 덮는다.
      useRootNavigator: true,
      builder: (context) => ConfirmDialog(
        icon: icon,
        title: title,
        description: description,
        confirmText: confirmText,
        cancelText: cancelText,
        destructive: destructive,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = destructive
        ? AppColors.danger
        : AppColors.primary;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.space3),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxDialogWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: destructive ? AppColors.dangerLight : AppColors.light,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: accentColor),
              ),
              const SizedBox(height: 17),
              Text(
                title,
                style: AppTextStyle.section,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                description,
                style: AppTextStyle.mainText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space5),
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      text: cancelText,
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.heading,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: CustomElevatedButton(
                      text: confirmText,
                      backgroundColor: accentColor,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
