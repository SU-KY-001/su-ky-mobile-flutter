import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/app/app.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/player/ui/player_screen.dart';
import 'package:su_ky_mobile/features/quiz/data/quiz_repository.dart';
import 'package:su_ky_mobile/features/quiz/domain/quiz.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_screen.dart';
import 'package:su_ky_mobile/features/quiz/ui/quiz_view_model.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';
import 'package:su_ky_mobile/shared/widgets/series_card.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class _Repository implements QuizRepository {
  QuizAttempt? stored;
  @override
  Future<Result<QuizAttempt?>> latest() async => Ok(stored);
  @override
  Future<Result<void>> save(QuizAttempt attempt) async {
    stored = attempt;
    return const Ok(null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Inter')
          ..addFont(
            rootBundle.load('assets/fonts/Inter/static/Inter_18pt-Regular.ttf'),
          )
          ..addFont(
            rootBundle.load('assets/fonts/Inter/static/Inter_18pt-Bold.ttf'),
          ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  for (final width in [390.0, 320.0]) {
    testWidgets('all quiz stages render and respond at width $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _Repository();
      var now = DateTime.utc(2026, 10, 30);
      final key = GlobalKey();
      final provider = quizViewModelProvider(1);
      var closed = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizRepositoryProvider.overrideWithValue(repository),
            quizClockProvider.overrideWithValue(() => now),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RepaintBoundary(
              key: key,
              child: QuizScreen(
                episode: 1,
                onClose: () => closed = true,
                onEpisode: () => closed = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(QuizScreen)),
      );
      final vm = container.read(provider.notifier);
      Future<void> capture(String name) async {
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('CAPTURE_UI') && width == 390) {
          await tester.runAsync(() async {
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final directory = Directory('build/ui_previews');
            await directory.create(recursive: true);
            await File('${directory.path}/quiz_$name.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }

      await tester.runAsync(
        () async => precacheImage(
          const AssetImage('assets/images/bach_dang.jpg'),
          key.currentContext!,
        ),
      );
      await capture('introduction');
      await tester.ensureVisible(find.text('Bắt đầu quiz'));
      await tester.tap(find.text('Bắt đầu quiz'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Kiểm tra đáp án'),
            )
            .onPressed,
        isNull,
      );
      await capture('question');
      final option = find.textContaining('A.  Vót nhọn');
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pump();
      await tester.tap(find.text('Kiểm tra đáp án'));
      await tester.pumpAndSettle();
      expect(find.text('Đáp án chính xác'), findsOneWidget);
      await capture('feedback');
      await tester.ensureVisible(find.text('Lời giải chi tiết'));
      await capture('feedback_explanation');
      await tester.tap(find.byTooltip('Đóng'));
      await tester.pumpAndSettle();
      expect(find.text('Thoát bài đang làm?'), findsOneWidget);
      await tester.tap(find.text('Tiếp tục làm'));
      await tester.pumpAndSettle();
      expect(closed, isFalse);
      now = now.add(const Duration(seconds: 225));
      await vm.next();
      for (var i = 1; i < QuizDefinition.questions.length; i++) {
        vm.select(i == 2 ? 0 : QuizDefinition.questions[i].correctOption);
        vm.check();
        await vm.next();
      }
      await capture('summary');
      expect(find.text('5/6 câu đúng'), findsOneWidget);
      expect(repository.stored!.percent, 83);
      await tester.ensureVisible(find.text('Xem lại chi tiết đáp án'));
      await tester.tap(find.text('Xem lại chi tiết đáp án'));
      await capture('review');
      await tester.tap(find.text('Câu sai (1)'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ai trực tiếp chỉ huy'), findsOneWidget);
      expect(find.textContaining('Cọc gỗ trong trận địa'), findsNothing);
      vm.summary();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Làm lại quiz'));
      await tester.tap(find.text('Làm lại quiz'));
      await tester.pumpAndSettle();
      expect(container.read(provider).requireValue.selected, isNull);
      await tester.tap(find.byTooltip('Đóng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thoát quiz'));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('quiz entry is reachable from the existing player', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [quizRepositoryProvider.overrideWithValue(_Repository())],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(SeriesCard).first);
    await tester.tap(find.byType(SeriesCard).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ôn tập với Quiz'));
    await tester.tap(find.text('Ôn tập với Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Ôn lại kiến thức'), findsOneWidget);
    await tester.ensureVisible(find.text('Quay về tập nghe'));
    await tester.tap(find.text('Quay về tập nghe'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết Series'), findsOneWidget);
    final episodeCard = find
        .ancestor(
          of: find.text('Ôn tập với Quiz'),
          matching: find.byType(Surface),
        )
        .first;
    final play = find.descendant(
      of: episodeCard,
      matching: find.byType(RoundPlay),
    );
    await tester.ensureVisible(play);
    await tester.tap(play);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ôn tập với Quiz'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Ôn tập với Quiz'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(QuizScreen)),
    );
    container.read(audioViewModelProvider.notifier).playEpisode(1);
    await tester.ensureVisible(find.text('Bắt đầu quiz'));
    await tester.tap(find.text('Bắt đầu quiz'));
    await tester.pumpAndSettle();
    expect(container.read(audioViewModelProvider).playing, isFalse);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thoát quiz'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
