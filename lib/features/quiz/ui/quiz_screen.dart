import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

import '../domain/quiz.dart';
import 'quiz_view_model.dart';

const _gold = Color(0xFF956400);
const _green = Color(0xFF214C40);
const _greenTint = Color(0xFFEDF5EF);
const _redTint = Color(0xFFFFF0ED);
const _soft = Color(0xFFF7F4EE);

class QuizScreen extends ConsumerWidget {
  const QuizScreen({
    super.key,
    required this.episode,
    required this.onClose,
    required this.onEpisode,
  });
  final int episode;
  final VoidCallback onClose;
  final VoidCallback onEpisode;

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
        final leave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.quizExitTitle),
            content: Text(l.quizExitBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.quizContinue),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.quizExit),
              ),
            ],
          ),
        );
        if (leave != true || !context.mounted) return;
        vm.abandon();
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted) return;
      }
      if (session?.stage == QuizStage.review) {
        vm.summary();
      } else {
        onClose();
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
          toolbarHeight: 84,
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
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l.quizHelp),
                  content: Text(l.quizHelpBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.close),
                    ),
                  ],
                ),
              ),
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
                      data: (s) => _content(context, l, s, vm),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l,
    QuizSession s,
    QuizViewModel vm,
  ) {
    if (s.stage == QuizStage.question) return _question(context, l, s, vm);
    return SingleChildScrollView(
      key: ValueKey(s.stage),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s.stage == QuizStage.introduction) ..._intro(context, l, s, vm),
          if (s.stage == QuizStage.summary) ..._summary(context, l, s, vm),
          if (s.stage == QuizStage.review) ..._review(context, l, s, vm),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _intro(
    BuildContext context,
    AppLocalizations l,
    QuizSession s,
    QuizViewModel vm,
  ) => [
    _episodeCard(context, l),
    const SizedBox(height: 20),
    _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(l.quizSubtitle.toUpperCase()),
          const SizedBox(height: 16),
          _heading(l.quizHeading),
          const SizedBox(height: 12),
          Text(
            l.quizIntro,
            style: const TextStyle(height: 1.65, color: AppDesign.muted),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _metric(
                  Icons.quiz_outlined,
                  l.quizQuestions(QuizDefinition.questions.length),
                  l.quizChoiceType,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metric(
                  Icons.schedule,
                  l.quizEstimate(QuizDefinition.estimatedMinutes),
                  l.quizEstimated,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    if (s.attempt case final attempt?) ...[
      const SizedBox(height: 20),
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                Text(
                  l.quizPrevious,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  DateFormat.yMd(
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(attempt.finishedAt.toLocal()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _heading(
              l.quizScore(
                attempt.correctCount,
                QuizDefinition.questions.length,
              ),
            ),
            Text(l.quizAccuracy(attempt.percent)),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: attempt.percent / 100,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    ],
    const SizedBox(height: 20),
    _card(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppDesign.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.quizTip,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(l.quizTipBody, style: const TextStyle(height: 1.6)),
              ],
            ),
          ),
        ],
      ),
      color: _soft,
    ),
    const SizedBox(height: 24),
    _primary(
      s.attempt == null ? l.quizStart : l.quizRestart,
      vm.start,
      icon: Icons.play_arrow,
    ),
    const SizedBox(height: 12),
    _secondary(l.quizReturnEpisode, onEpisode, Icons.menu_book_outlined),
    const SizedBox(height: 12),
    Text(
      l.quizLocalNote,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 11, color: AppDesign.muted),
    ),
    if (s.saveFailed)
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(l.quizStorageError),
      ),
  ];

  Widget _question(
    BuildContext context,
    AppLocalizations l,
    QuizSession s,
    QuizViewModel vm,
  ) {
    final (question, options, explanation) = _text(l, s.question.id);
    final total = QuizDefinition.questions.length;
    final progress = (s.questionIndex + 1) / total;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(s.questionIndex),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _eyebrow(l.quizProgress)),
                    Text(
                      l.quizCounter(s.questionIndex + 1, total),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(5),
                  backgroundColor: AppDesign.line,
                ),
                const SizedBox(height: 22),
                if (s.checked) ...[
                  const CoverArt(height: 135),
                  const SizedBox(height: 20),
                ],
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(
                          l.quizCategory,
                          style: const TextStyle(fontFamily: 'Inter'),
                        ),
                        backgroundColor: const Color(0xFFFFE8BD),
                        labelStyle: const TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _heading(question, size: 21),
                      if (!s.checked) ...[
                        const SizedBox(height: 16),
                        Text(
                          l.quizInstruction,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppDesign.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _option(l, s, vm, options[i], i),
                  ),
                if (s.checked)
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              s.isCorrect ? Icons.check_circle : Icons.cancel,
                              color: s.isCorrect ? _green : AppDesign.red,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _heading(
                                s.isCorrect ? l.quizCorrect : l.quizIncorrect,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        _eyebrow(l.quizExplanation),
                        const SizedBox(height: 12),
                        Text(explanation, style: const TextStyle(height: 1.7)),
                        const SizedBox(height: 16),
                        Text(
                          l.quizSource,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppDesign.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: _primary(
              s.checked ? (s.isLast ? l.quizFinish : l.quizNext) : l.quizCheck,
              s.saving || (!s.checked && s.selected == null)
                  ? null
                  : () {
                      if (s.checked) {
                        vm.next();
                      } else {
                        vm.check();
                      }
                    },
              icon: Icons.arrow_forward,
            ),
          ),
        ),
      ],
    );
  }

  Widget _option(
    AppLocalizations l,
    QuizSession s,
    QuizViewModel vm,
    String text,
    int index,
  ) {
    final selected = s.selected == index;
    final correct = s.checked && s.question.correctOption == index;
    final wrong = s.checked && selected && !correct;
    final color = correct
        ? _green
        : wrong || selected
        ? AppDesign.red
        : AppDesign.line;
    return Material(
      color: correct
          ? _greenTint
          : wrong
          ? _redTint
          : selected
          ? AppDesign.tint
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: selected || correct ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: s.checked ? null : () => vm.select(index),
        child: Semantics(
          selected: selected,
          label: correct ? l.quizRightAnswer : null,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  correct
                      ? Icons.check_circle
                      : wrong
                      ? Icons.cancel
                      : selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: color == AppDesign.line ? AppDesign.muted : color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${String.fromCharCode(65 + index)}.  $text',
                        style: TextStyle(
                          height: 1.6,
                          fontWeight: selected || correct
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (correct) ...[
                        const SizedBox(height: 8),
                        Text(
                          l.quizRightAnswer,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _green,
                          ),
                        ),
                      ],
                      if (wrong) ...[
                        const SizedBox(height: 8),
                        Text(
                          l.quizYourAnswer,
                          style: const TextStyle(color: AppDesign.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _summary(
    BuildContext context,
    AppLocalizations l,
    QuizSession s,
    QuizViewModel vm,
  ) {
    final attempt = s.attempt!;
    final count = QuizDefinition.questions.length;
    return [
      const SizedBox(height: 20),
      const Icon(Icons.workspace_premium_outlined, size: 100, color: _gold),
      const SizedBox(height: 20),
      Text(
        l.quizScore(attempt.correctCount, count),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      Text(
        l.quizAccuracy(attempt.percent),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _gold,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        attempt.percent >= 80 ? l.quizExcellent : l.quizEncourage,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w800,
          color: AppDesign.red,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        l.quizResultBody,
        textAlign: TextAlign.center,
        style: const TextStyle(height: 1.7, color: AppDesign.muted),
      ),
      const SizedBox(height: 28),
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _heading(l.quizStatistics, size: 20),
            const SizedBox(height: 16),
            _stat(
              Icons.schedule,
              l.quizElapsed,
              l.quizDuration(
                attempt.elapsedSeconds ~/ 60,
                attempt.elapsedSeconds % 60,
              ),
            ),
            _stat(
              Icons.check_circle_outline,
              l.quizRightCount,
              '${attempt.correctCount}',
              color: _green,
            ),
            _stat(
              Icons.error_outline,
              l.quizWrongCount,
              '${count - attempt.correctCount}',
              color: AppDesign.red,
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _episodeCard(context, l),
      const SizedBox(height: 24),
      if (s.saving) ...[
        const LinearProgressIndicator(),
        const SizedBox(height: 8),
        Text(l.quizSaving),
        const SizedBox(height: 12),
      ],
      if (s.saveFailed) ...[
        Text(l.quizStorageError),
        TextButton(
          onPressed: s.saving ? null : vm.retrySave,
          child: Text(l.quizRetrySave),
        ),
      ],
      _primary(l.quizReview, vm.review, icon: Icons.format_list_bulleted),
      const SizedBox(height: 12),
      _secondary(l.quizRestart, s.saving ? null : vm.start, Icons.replay),
      const SizedBox(height: 12),
      _secondary(l.quizReturnEpisode, onEpisode, Icons.arrow_back),
      const SizedBox(height: 16),
      Text(
        l.quizLocalNote,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: AppDesign.muted),
      ),
    ];
  }

  List<Widget> _review(
    BuildContext context,
    AppLocalizations l,
    QuizSession s,
    QuizViewModel vm,
  ) {
    final attempt = s.attempt!;
    final total = QuizDefinition.questions.length;
    final indices = [
      for (var i = 0; i < total; i++)
        if (s.filter == QuizFilter.all ||
            (attempt.answers[i] == QuizDefinition.questions[i].correctOption) ==
                (s.filter == QuizFilter.correct))
          i,
    ];
    return [
      _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(l.bachDang, size: 22),
            const SizedBox(height: 10),
            Text(l.quizScore(attempt.correctCount, total)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: attempt.percent / 100,
              color: _green,
              backgroundColor: AppDesign.red,
              minHeight: 6,
            ),
            const SizedBox(height: 12),
            Text(l.quizAccuracy(attempt.percent)),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: Text(
              l.quizFilterAll(total),
              style: TextStyle(
                fontFamily: 'Inter',
                color: s.filter == QuizFilter.all
                    ? Colors.white
                    : AppDesign.ink,
              ),
            ),
            selected: s.filter == QuizFilter.all,
            onSelected: (_) => vm.filter(QuizFilter.all),
          ),
          ChoiceChip(
            label: Text(
              l.quizFilterWrong(total - attempt.correctCount),
              style: TextStyle(
                fontFamily: 'Inter',
                color: s.filter == QuizFilter.incorrect
                    ? Colors.white
                    : AppDesign.ink,
              ),
            ),
            selected: s.filter == QuizFilter.incorrect,
            onSelected: (_) => vm.filter(QuizFilter.incorrect),
          ),
          ChoiceChip(
            label: Text(
              l.quizFilterRight(attempt.correctCount),
              style: TextStyle(
                fontFamily: 'Inter',
                color: s.filter == QuizFilter.correct
                    ? Colors.white
                    : AppDesign.ink,
              ),
            ),
            selected: s.filter == QuizFilter.correct,
            onSelected: (_) => vm.filter(QuizFilter.correct),
          ),
        ],
      ),
      const SizedBox(height: 18),
      if (indices.isEmpty)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l.quizNoMatches),
        ),
      for (final i in indices) ...[
        _reviewQuestion(l, attempt, i),
        const SizedBox(height: 14),
      ],
      const SizedBox(height: 12),
      _primary(l.quizBackResults, vm.summary, icon: Icons.arrow_back),
    ];
  }

  Widget _reviewQuestion(AppLocalizations l, QuizAttempt attempt, int i) {
    final definition = QuizDefinition.questions[i];
    final (question, options, explanation) = _text(l, definition.id);
    final correct = attempt.answers[i] == definition.correctOption;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppDesign.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: ValueKey(definition.id),
        initiallyExpanded: !correct,
        leading: Icon(
          correct ? Icons.check_circle : Icons.cancel,
          color: correct ? _green : AppDesign.red,
        ),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, height: 1.5),
        ),
        subtitle: Text(
          '${l.quizCounter(i + 1, QuizDefinition.questions.length)} · ${correct ? l.quizCorrect : l.quizIncorrect}',
          style: TextStyle(
            fontSize: 11,
            color: correct ? _green : AppDesign.red,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          if (!correct) ...[
            _answer(l.quizYourAnswer, options[attempt.answers[i]], _redTint),
            const SizedBox(height: 10),
          ],
          _answer(
            l.quizRightAnswer,
            options[definition.correctOption],
            _greenTint,
          ),
          const SizedBox(height: 10),
          _answer(l.quizExplanation, explanation, _soft),
        ],
      ),
    );
  }

  Widget _episodeCard(BuildContext context, AppLocalizations l) => _card(
    Row(
      children: [
        const CoverArt(height: 72, width: 72),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.bachDang.toUpperCase(),
                style: const TextStyle(
                  color: _gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.playerTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _answer(String label, String body, Color color) => SizedBox(
    width: double.infinity,
    child: _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(height: 1.6)),
        ],
      ),
      color: color,
    ),
  );

  Widget _stat(
    IconData icon,
    String label,
    String value, {
    Color color = AppDesign.ink,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: _card(
      Row(
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
      color: _soft,
    ),
  );
  Widget _metric(IconData icon, String title, String subtitle) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _gold),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppDesign.muted),
        ),
      ],
    ),
    color: _soft,
  );
  Widget _eyebrow(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: .5,
      color: AppDesign.red,
    ),
  );
  Widget _heading(String text, {double size = 27}) => Text(
    text,
    style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, height: 1.4),
  );
  Widget _card(Widget child, {Color color = Colors.white}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppDesign.line),
    ),
    child: child,
  );
  Widget _primary(
    String text,
    VoidCallback? onTap, {
    IconData icon = Icons.arrow_forward,
  }) => FilledButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 21),
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
  Widget _secondary(String text, VoidCallback? onTap, IconData icon) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 21),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 17),
          child: Text(text, textAlign: TextAlign.center),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

  (String, List<String>, String) _text(AppLocalizations l, String id) {
    final (question, options, explanation) = switch (id) {
      'stakes' => (l.quizQuestion1, l.quizOptions1, l.quizExplanation1),
      'tide' => (l.quizQuestion2, l.quizOptions2, l.quizExplanation2),
      'commander' => (l.quizQuestion3, l.quizOptions3, l.quizExplanation3),
      'timing' => (l.quizQuestion4, l.quizOptions4, l.quizExplanation4),
      'meaning' => (l.quizQuestion5, l.quizOptions5, l.quizExplanation5),
      _ => (l.quizQuestion6, l.quizOptions6, l.quizExplanation6),
    };
    return (question, options.split(' | '), explanation);
  }
}
