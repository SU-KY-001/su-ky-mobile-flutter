import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/app/theme/app_theme.dart';
import 'package:su_ky_mobile/core/activity/learning_activity.dart';
import 'package:su_ky_mobile/core/auth/signed_in.dart';
import 'package:su_ky_mobile/core/di/app_retry.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/weekly_missions/ui/weekly_missions_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/missions/data/weekly_missions_repository.dart';
import 'package:su_ky_mobile/shared/missions/domain/weekly_missions.dart';
import 'package:su_ky_mobile/shared/missions/missions_providers.dart';

import '../../support/stub_http.dart';

Map<String, Object?> _mission({
  String id = 'm1',
  String activity = 'COMPLETE_EPISODE',
  String status = 'IN_PROGRESS',
  int target = 3,
  int progress = 1,
}) => {
  'id': id,
  'title': 'Hoàn thành 3 tập',
  'activityType': activity,
  'targetCount': target,
  'progressCount': progress,
  'xpReward': 50,
  'completedAt': null,
  'status': status,
};

Map<String, Object?> _body(List<Object?> items, {int xp = 120}) => {
  'weekStartDate': '2026-11-02T00:00:00.000Z',
  'weekEndDate': '2026-11-09T00:00:00.000Z',
  'totalXp': xp,
  'items': items,
};

ApiWeeklyMissionsRepository _repo(StubReply reply) =>
    ApiWeeklyMissionsRepository(stubDio((_) => reply).$1);

class _Repo implements WeeklyMissionsRepository {
  _Repo(this.answer);
  Result<WeeklyMissions> Function() answer;
  int calls = 0;

  @override
  Future<Result<WeeklyMissions>> fetch() async {
    calls++;
    return answer();
  }
}

WeeklyMissions _missions({int xp = 120, List<WeeklyMission>? items}) =>
    WeeklyMissions(
      totalXp: xp,
      weekEnd: DateTime.utc(2026, 11, 9),
      items:
          items ??
          const [
            WeeklyMission(
              id: 'm1',
              title: 'Hoàn thành 3 tập',
              activity: MissionActivity.completeEpisode,
              targetCount: 3,
              progressCount: 1,
              xpReward: 50,
              status: MissionStatus.inProgress,
            ),
            WeeklyMission(
              id: 'm2',
              title: 'Đậu 1 quiz',
              activity: MissionActivity.passQuiz,
              targetCount: 1,
              progressCount: 1,
              xpReward: 30,
              status: MissionStatus.completed,
            ),
          ],
    );

void main() {
  group('ApiWeeklyMissionsRepository', () {
    test('parses XP, week end (UTC) and counts completed missions', () async {
      final r = await _repo(
        StubReply(
          200,
          _body([
            _mission(),
            _mission(id: 'm2', status: 'COMPLETED', progress: 3),
          ]),
        ),
      ).fetch();
      final m = (r as Ok<WeeklyMissions>).value;
      expect(m.totalXp, 120);
      expect(m.weekEnd, DateTime.utc(2026, 11, 9));
      expect(m.weekEnd.isUtc, isTrue);
      expect(m.completedCount, 1);
      expect(m.items.first.progress, closeTo(1 / 3, 1e-9));
    });

    test('unknown activity or status is skipped, the rest is kept', () async {
      final r = await _repo(
        StubReply(
          200,
          _body([
            _mission(activity: 'SHARE'),
            _mission(id: 'm3', status: 'PAUSED'),
            _mission(id: 'm4'),
          ]),
        ),
      ).fetch();
      expect((r as Ok<WeeklyMissions>).value.items.map((i) => i.id), ['m4']);
    });

    test('progress is clamped and a zero target means no progress', () {
      const over = WeeklyMission(
        id: 'a',
        title: 't',
        activity: MissionActivity.passQuiz,
        targetCount: 2,
        progressCount: 5,
        xpReward: 1,
        status: MissionStatus.completed,
      );
      const zero = WeeklyMission(
        id: 'b',
        title: 't',
        activity: MissionActivity.passQuiz,
        targetCount: 0,
        progressCount: 0,
        xpReward: 1,
        status: MissionStatus.inProgress,
      );
      expect(over.progress, 1.0);
      expect(zero.progress, 0.0);
    });

    test(
      'missing items, negative counts and bad dates fail the response',
      () async {
        expect(
          await _repo(const StubReply(200, {'totalXp': 1})).fetch(),
          isA<Err<WeeklyMissions>>(),
        );
        expect(
          await _repo(StubReply(200, _body([_mission(target: -1)]))).fetch(),
          isA<Err<WeeklyMissions>>(),
        );
        expect(
          await _repo(StubReply(200, {..._body([]), 'weekEndDate': 'soon'}))
              .fetch(),
          isA<Err<WeeklyMissions>>(),
        );
      },
    );

    test('401 is an ApiException', () async {
      final r = await _repo(
        const StubReply(401, {'error_code': 'UNAUTHORIZED'}),
      ).fetch();
      expect(
        ((r as Err<WeeklyMissions>).error as ApiException).statusCode,
        401,
      );
    });
  });

  group('weeklyMissionsProvider', () {
    ProviderContainer container(_Repo repo, {required bool signedIn}) {
      final c = ProviderContainer(
        retry: appRetry,
        overrides: [
          signedInProvider.overrideWithValue(signedIn),
          weeklyMissionsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(c.dispose);
      c.listen(weeklyMissionsProvider, (_, _) {});
      return c;
    }

    test('guests get null and no request', () async {
      final repo = _Repo(() => Ok(_missions()));
      final c = container(repo, signedIn: false);
      expect(await c.read(weeklyMissionsProvider.future), isNull);
      expect(repo.calls, 0);
    });

    test('refreshes when a learning activity finishes', () async {
      var xp = 120;
      final repo = _Repo(() => Ok(_missions(xp: xp)));
      final c = container(repo, signedIn: true);
      expect((await c.read(weeklyMissionsProvider.future))?.totalXp, 120);
      xp = 170;
      c.read(learningActivityProvider.notifier).bump();
      expect((await c.read(weeklyMissionsProvider.future))?.totalXp, 170);
      expect(repo.calls, 2);
    });

    test('a request error surfaces as AsyncError', () async {
      final repo = _Repo(() => const Err(ApiException('x', statusCode: 403)));
      final c = container(repo, signedIn: true);
      await expectLater(
        c.read(weeklyMissionsProvider.future),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('WeeklyMissionsScreen', () {
    Future<void> pump(
      WidgetTester tester,
      _Repo repo, {
      bool signedIn = true,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          retry: appRetry,
          overrides: [
            signedInProvider.overrideWithValue(signedIn),
            weeklyMissionsRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const WeeklyMissionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    AppLocalizations l(WidgetTester t) =>
        AppLocalizations.of(t.element(find.byType(WeeklyMissionsScreen)));

    testWidgets('shows XP and every mission title', (tester) async {
      await pump(tester, _Repo(() => Ok(_missions())));
      expect(find.text('Hoàn thành 3 tập'), findsOneWidget);
      expect(find.text('Đậu 1 quiz'), findsOneWidget);
      expect(find.text(l(tester).missionsListTitle), findsOneWidget);
    });

    testWidgets('a guest sees the sign-in prompt', (tester) async {
      await pump(tester, _Repo(() => Ok(_missions())), signedIn: false);
      expect(find.text(l(tester).missionsGuestTitle), findsOneWidget);
    });

    testWidgets('no missions shows the empty state', (tester) async {
      await pump(tester, _Repo(() => Ok(_missions(items: const []))));
      expect(find.text(l(tester).missionsEmptyTitle), findsOneWidget);
    });

    testWidgets('an error offers retry and recovers', (tester) async {
      final repo = _Repo(() => const Err(ApiException('x', statusCode: 403)));
      await pump(tester, repo);
      final retry = find.text(l(tester).catalogRetry);
      expect(retry, findsOneWidget);
      repo.answer = () => Ok(_missions());
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(find.text('Hoàn thành 3 tập'), findsOneWidget);
    });
  });
}
