import 'package:flutter/material.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/mission_widgets.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class MissionCondition extends StatelessWidget {
  const MissionCondition({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.color,
    this.icon,
    this.number,
  });

  final String title, description, status;
  final String? number;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Surface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: icon != null
                ? Icon(icon, size: 18, color: Colors.white)
                : Text(
                    number!,
                    style: context.text.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.text.bodySmall?.copyWith(
                    color: AppDesign.muted,
                  ),
                ),
                MissionDesign.smallGap,
                Text(
                  status,
                  style: context.text.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
