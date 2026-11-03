import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'quiz_colors.dart';
import 'quiz_option_tile.dart';
import 'quiz_primitives.dart';
import 'quiz_session.dart';
import 'quiz_view_model.dart';

const _contentPadding = 20.0;
const _progressHeight = 6.0;
const _progressRadius = 5.0;
const _sectionGap = 22.0;
const _optionsGap = 16.0;
const _questionHeadingSize = 21.0;
const _optionGap = 12.0;
const _buttonPadding = EdgeInsets.fromLTRB(20, 12, 20, 16);
const _spinnerSize = 18.0;
const _spinnerStroke = 2.0;
const _spinnerGap = 10.0;
const _errorGap = 8.0;

class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({
    super.key,
    required this.session,
    required this.viewModel,
  });

  final QuizSession session;
  final QuizViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final question = session.question;
    final submitting = session.submitting;
    final canAdvance = session.selectedOptionId != null && !submitting;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(session.index),
            padding: const EdgeInsets.all(_contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: QuizEyebrow(l.quizProgress)),
                    Text(
                      l.quizCounter(session.index + 1, session.total),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: _optionGap),
                LinearProgressIndicator(
                  value: (session.index + 1) / session.total,
                  minHeight: _progressHeight,
                  borderRadius: BorderRadius.circular(_progressRadius),
                  backgroundColor: AppDesign.line,
                ),
                const SizedBox(height: _sectionGap),
                QuizCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QuizHeading(question.text, size: _questionHeadingSize),
                      const SizedBox(height: _optionGap),
                      Text(
                        l.quizInstruction,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppDesign.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _optionsGap),
                for (final option in question.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: _optionGap),
                    child: QuizOptionTile(
                      option: option,
                      selected: session.selectedOptionId == option.id,
                      onSelect: viewModel.select,
                    ),
                  ),
                if (session.submitError != null) _SubmitError(viewModel),
              ],
            ),
          ),
        ),
        Padding(
          padding: _buttonPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (submitting) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: _spinnerSize,
                      height: _spinnerSize,
                      child: CircularProgressIndicator(
                        strokeWidth: _spinnerStroke,
                      ),
                    ),
                    const SizedBox(width: _spinnerGap),
                    Text(l.quizSubmitting),
                  ],
                ),
                const SizedBox(height: _spinnerGap),
              ],
              SizedBox(
                width: double.infinity,
                child: QuizPrimaryButton(
                  session.isLast ? l.quizSubmit : l.quizNext,
                  canAdvance ? viewModel.next : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubmitError extends StatelessWidget {
  const _SubmitError(this.viewModel);

  final QuizViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return QuizCard(
      color: QuizColors.redTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.quizSubmitFailed,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppDesign.red,
            ),
          ),
          const SizedBox(height: _errorGap),
          TextButton(onPressed: viewModel.submit, child: Text(l.quizRetry)),
        ],
      ),
    );
  }
}
