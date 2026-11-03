import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'quiz_colors.dart';
import 'quiz_primitives.dart';

const _metricGap = 12.0;
const _labelGap = 4.0;
const _answerGap = 8.0;
const _subtitleSize = 12.0;
const _bodyHeight = 1.6;

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
        const SizedBox(height: _metricGap),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: _labelGap),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: _subtitleSize,
            color: AppDesign.muted,
          ),
        ),
      ],
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
          const SizedBox(height: _answerGap),
          Text(body, style: const TextStyle(height: _bodyHeight)),
        ],
      ),
    ),
  );
}
