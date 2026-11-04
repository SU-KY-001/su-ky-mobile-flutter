import 'package:flutter/material.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import 'quiz_bottom_bar.dart';
import 'quiz_option_tile.dart';
import 'quiz_session.dart';
import 'quiz_view_model.dart';

const _questionSize = 24.0;
const _questionGap = 24.0;
const _optionGap = 12.0;

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
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: _questionSize,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: _questionGap),
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
        QuizBottomBar(
          label: submitting
              ? l.quizSubmitting
              : session.isLast
              ? l.quizSubmit
              : l.quizNext,
          onPressed: canAdvance ? viewModel.next : null,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.quizSubmitFailed,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppDesign.red,
          ),
        ),
        TextButton(onPressed: viewModel.submit, child: Text(l.quizRetry)),
      ],
    );
  }
}
