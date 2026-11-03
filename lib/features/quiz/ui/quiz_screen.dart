import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

import '../domain/quiz.dart';
import 'quiz_dialogs.dart';
import 'quiz_intro_view.dart';
import 'quiz_navigation.dart';
import 'quiz_question_view.dart';
import 'quiz_review_view.dart';
import 'quiz_summary_view.dart';
import 'quiz_view_model.dart';

const _toolbarHeight = 84.0;

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.episode});
  final int episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final provider = quizViewModelProvider(episode);
    final async = ref.watch(provider);
    final vm = ref.read(provider.notifier);
    final session = async.asData?.value;
    final active = session?.stage == QuizStage.question;

    Future<void> leave() async {
      if (active) {
        if (!await confirmQuizExit(context) || !context.mounted) return;
        vm.abandon();
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted) return;
      }
      if (session?.stage == QuizStage.review) {
        vm.summary();
      } else {
        leaveQuiz(context);
      }
    }

    return PopScope(
      canPop: !active && session?.stage != QuizStage.review,
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
                session?.stage == QuizStage.review
                    ? l.quizReviewTitle
                    : session?.stage == QuizStage.summary
                    ? l.quizResults
                    : l.quizTitle,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                l.quizSubtitle,
                style: const TextStyle(fontSize: 12, color: AppDesign.muted),
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
              child: episode != QuizDefinition.episode
                  ? Center(child: Text(l.quizUnavailable))
                  : async.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l.quizLoadError),
                            TextButton(
                              onPressed: () => ref.invalidate(provider),
                              child: Text(l.quizRetry),
                            ),
                          ],
                        ),
                      ),
                      data: (s) => _content(s, vm),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(QuizSession s, QuizViewModel vm) {
    if (s.stage == QuizStage.question) {
      return QuizQuestionView(session: s, vm: vm);
    }
    return SingleChildScrollView(
      key: ValueKey(s.stage),
      padding: const EdgeInsets.all(20),
      child: switch (s.stage) {
        QuizStage.introduction => QuizIntroView(session: s, vm: vm),
        QuizStage.summary => QuizSummaryView(session: s, vm: vm),
        _ => QuizReviewView(session: s, vm: vm),
      },
    );
  }
}
