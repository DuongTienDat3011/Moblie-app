import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum TimelineItemState { done, active, todo }

class TimelineItem {
  final String title;
  final String? time;
  final TimelineItemState state;

  const TimelineItem({
    required this.title,
    this.time,
    this.state = TimelineItemState.todo,
  });
}

class TimelineWidget extends StatelessWidget {
  final List<TimelineItem> items;

  const TimelineWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        final isLast = i == items.length - 1;

        Color dotColor;
        Widget dotChild;
        switch (item.state) {
          case TimelineItemState.done:
            dotColor = AppColors.primaryGreen;
            dotChild = const Icon(Icons.check, size: 13, color: Colors.white);
            break;
          case TimelineItemState.active:
            dotColor = AppColors.blue;
            dotChild = Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            );
            break;
          case TimelineItemState.todo:
            dotColor = AppColors.divider;
            dotChild = const SizedBox.shrink();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: item.state == TimelineItemState.active
                        ? [BoxShadow(color: AppColors.blue.withOpacity(0.25),
                                     blurRadius: 8, spreadRadius: 2)]
                        : null,
                  ),
                  child: Center(child: dotChild),
                ),
                if (!isLast)
                  Container(
                    width: 2, height: 40,
                    color: item.state == TimelineItemState.done
                        ? AppColors.primaryGreen
                        : AppColors.divider,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.state == TimelineItemState.todo
                            ? FontWeight.normal : FontWeight.w600,
                        color: item.state == TimelineItemState.todo
                            ? AppColors.textHint : AppColors.textPrimary,
                      ),
                    ),
                    if (item.time != null) ...[
                      const SizedBox(height: 2),
                      Text(item.time!, style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
