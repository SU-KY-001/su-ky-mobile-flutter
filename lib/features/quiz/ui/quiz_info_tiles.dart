import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'quiz_colors.dart';
import 'quiz_primitives.dart';

class QuizMetric extends StatelessWidget {
  const QuizMetric({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => QuizCard(
    color: QuizColors.soft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: QuizColors.gold),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppDesign.muted),
        ),
      ],
    ),
  );
}

class QuizStat extends StatelessWidget {
  const QuizStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppDesign.ink,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: QuizCard(
      color: QuizColors.soft,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    ),
  );
}

class QuizAnswerBox extends StatelessWidget {
  const QuizAnswerBox({
    super.key,
    required this.label,
    required this.body,
    required this.color,
  });
  final String label;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: QuizCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(height: 1.6)),
        ],
      ),
    ),
  );
}
