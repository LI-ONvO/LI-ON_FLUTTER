import 'package:flutter/material.dart';
import 'package:li_on/core/constants/color.dart';
import 'package:li_on/core/constants/font.dart';
import 'package:li_on/core/constants/spacing.dart';
import 'package:li_on/pages/calendar/model/calendar_event.dart';
import 'package:li_on/pages/data_room/widget/material_more_button.dart';

/// 선택한 날짜의 일정 한 줄. 탭하면 상세(수정 폼)를 열고, ⋮ 메뉴로 수정·삭제할 수 있다.
class CalendarEventTile extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CalendarEventTile({
    super.key,
    required this.event,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // ⋮ 버튼을 상세 탭 영역 밖의 형제로 둔다. 버튼을 감싸는 큰 GestureDetector
    // 안에 작은 GestureDetector를 중첩하면 버튼을 눌러도 바깥쪽 onTap이
    // 함께 반응해 메뉴 대신 상세 화면이 열려버리기 때문이다.
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.space1),
      child: Container(
        height: 56,
        color: AppColors.surface,
        child: Row(
          children: [
            Container(width: 4, color: AppColors.primary),
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.title,
                        style: AppTextStyle.card,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(event.timeLabel, style: AppTextStyle.subText),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space1),
              child: MaterialMoreButton(
                iconSize: 18,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
