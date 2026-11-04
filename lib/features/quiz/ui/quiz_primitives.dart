import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _buttonVerticalPadding = 17.0;
const _buttonIconSize = 21.0;
const _secondaryRadius = 14.0;
const _cardRadius = 20.0;
const _eyebrowSpacing = .5;
const _headingSize = 27.0;

class QuizCard extends StatelessWidget {
  const QuizCard({
    super.key,
    required this.child,
    this.color = AppDesign.white,
  });
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(_cardRadius),
      border: Border.all(color: AppDesign.line),
    ),
    child: child,
  );
}

class QuizEyebrow extends StatelessWidget {
  const QuizEyebrow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: _eyebrowSpacing,
      color: AppDesign.red,
    ),
  );
}

class QuizHeading extends StatelessWidget {
  const QuizHeading(this.text, {super.key, this.size = _headingSize});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, height: 1.4),
  );
}

class QuizPrimaryButton extends StatelessWidget {
  const QuizPrimaryButton(
    this.text,
    this.onTap, {
    super.key,
    this.icon = Icons.arrow_forward,
  });
  final String text;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: _buttonIconSize),
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}

class QuizSecondaryButton extends StatelessWidget {
  const QuizSecondaryButton(this.text, this.onTap, this.icon, {super.key});
  final String text;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: _buttonIconSize),
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
      child: Text(text, textAlign: TextAlign.center),
    ),
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_secondaryRadius),
      ),
    ),
  );
}
