import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';

import '../data/quiz_constants.dart';
import '../domain/quiz_stage.dart';
import 'quiz_dialogs.dart';
import 'quiz_intro_view.dart';
import 'quiz_navigation.dart';
import 'quiz_question_view.dart';
import 'quiz_review_view.dart';
import 'quiz_session.dart';
import 'quiz_summary_view.dart';
import 'quiz_view_model.dart';

const _toolbarHeight = 84.0;
const _contentPadding = 20.0;
const _titleSize = 19.0;
const _subtitleSize = 12.0;
const _stateGap = 24.0;
const _stateTextGap = 12.0;

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final provider = quizViewModelProvider(slug);
    final async = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);
    final session = async.asData?.value;
    final stage = session?.stage;
    final active = stage == QuizStage.question;

    Future<void> leave() async {
      if (active) {
        if (!await confirmQuizExit(context) || !context.mounted) return;
        viewModel.abandon();
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted) return;
      }
      if (stage == QuizStage.review) {
        viewModel.summary();
      } else {
        leaveQuiz(context);
      }
    }

    return PopScope(
      canPop: !active && stage != QuizStage.review,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) leave();
      },
      child: Scaffold(
        backgroundColor: AppDesign.white,
        appBar: AppBar(
          backgroundColor: AppDesign.white,
          toolbarHeight: _toolbarHeight,
          leading: IconButton(
            onPressed: leave,
            tooltip: l.close,
            icon: const Icon(Icons.close),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stage == QuizStage.review
                    ? l.quizReviewTitle
                    : stage == QuizStage.summary
                    ? l.quizResults
                    : l.quizTitle,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: _titleSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                l.quizSubtitle,
                style: const TextStyle(
                  fontSize: _subtitleSize,
                  color: AppDesign.muted,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: l.quizHelp,
              icon: const Icon(Icons.help_outline),
              onPressed: () => showQuizHelp(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDesign.maxWidth),
              child: async.when(
                loading: () => const CatalogLoading(),
                error: (error, _) => _QuizError(
                  error: error,
                  onRetry: () => ref.invalidate(provider),
                ),
                data: (value) => _content(value, viewModel),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(QuizSession session, QuizViewModel viewModel) {
    if (session.stage == QuizStage.question) {
      return QuizQuestionView(session: session, viewModel: viewModel);
    }
    return SingleChildScrollView(
      key: ValueKey(session.stage),
      padding: const EdgeInsets.all(_contentPadding),
      child: switch (session.stage) {
        QuizStage.summary =>
          session.result == null
              ? QuizIntroView(
                  session: session,
                  viewModel: viewModel,
                  slug: slug,
                )
              : QuizSummaryView(
                  session: session,
                  viewModel: viewModel,
                  slug: slug,
                ),
        QuizStage.review =>
          session.result == null
              ? QuizIntroView(
                  session: session,
                  viewModel: viewModel,
                  slug: slug,
                )
              : QuizReviewView(session: session, viewModel: viewModel),
        _ => QuizIntroView(session: session, viewModel: viewModel, slug: slug),
      },
    );
  }
}

class _QuizError extends StatelessWidget {
  const _QuizError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final failure = error;
    if (failure is ApiException &&
        failure.statusCode == QuizDefaults.notFoundStatus) {
      return CatalogEmpty(title: l.quizNotFound, message: l.quizUnavailable);
    }
    return Padding(
      padding: const EdgeInsets.all(_stateGap),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            failure is NetworkException
                ? l.catalogErrorNetwork
                : l.quizLoadFailed,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(color: AppDesign.muted),
          ),
          const SizedBox(height: _stateTextGap),
          OutlinedButton(onPressed: onRetry, child: Text(l.quizRetry)),
        ],
      ),
    );
  }
}
