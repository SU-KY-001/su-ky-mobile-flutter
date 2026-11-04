import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/catalog_states.dart';

import '../data/quiz_constants.dart';
import '../domain/quiz_stage.dart';
import 'quiz_dialogs.dart';
import 'quiz_intro_view.dart';
import 'quiz_navigation.dart';
import 'quiz_progress_bar.dart';
import 'quiz_question_view.dart';
import 'quiz_review_view.dart';
import 'quiz_session.dart';
import 'quiz_summary_view.dart';
import 'quiz_view_model.dart';

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
        final confirmed = await viewModel.confirmExit(
          () => confirmQuizExit(context),
        );
        if (!confirmed || !context.mounted) return;
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
          leading: IconButton(
            onPressed: leave,
            tooltip: l.close,
            icon: const Icon(Symbols.close),
          ),
          title: switch (stage) {
            QuizStage.question when session != null => QuizProgressBar(
              value: (session.index + 1) / session.total,
            ),
            QuizStage.review => Text(l.quizReviewTitle),
            _ => null,
          },
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
    final intro = QuizIntroView(
      key: ValueKey(session.stage),
      session: session,
      viewModel: viewModel,
      slug: slug,
    );
    if (session.stage == QuizStage.question) {
      return QuizQuestionView(session: session, viewModel: viewModel);
    }
    if (session.result == null) return intro;
    return switch (session.stage) {
      QuizStage.summary => QuizSummaryView(
        session: session,
        viewModel: viewModel,
      ),
      QuizStage.review => QuizReviewView(
        session: session,
        viewModel: viewModel,
      ),
      _ => intro,
    };
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
