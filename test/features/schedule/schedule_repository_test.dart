import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/schedule/data/schedule_repository.dart';
import 'package:su_ky_mobile/features/schedule/domain/release.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final String body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_FakeAdapter adapter) => Dio()..httpClientAdapter = adapter;

String _release({
  String id = 'release-1',
  String title = 'Episode title',
  String scheduledAt = '2026-01-05T09:00:00.000Z',
  bool released = true,
  String episodeSlug = 'episode-slug',
  String seriesTitle = 'Series title',
}) =>
    '{"id":"$id","title":"$title","scheduledAt":"$scheduledAt",'
    '"released":$released,"episodeSlug":"$episodeSlug",'
    '"series":{"id":"series-1","title":"$seriesTitle","slug":"series-slug"}}';

void main() {
  test('requests the local month as UTC and stays under 62 days', () async {
    final adapter = _FakeAdapter('{"items":[]}');
    final result = await ApiScheduleRepository(_dioWith(adapter))
        .month(DateTime(2026, 12));

    expect(result, isA<Ok<List<Release>>>());
    expect(adapter.lastRequest?.path, '/api/showcase/releases');
    final query = adapter.lastRequest!.queryParameters;
    final from = DateTime.parse(query['from']! as String);
    final to = DateTime.parse(query['to']! as String);
    expect(from, DateTime(2026, 12).toUtc());
    expect(to, DateTime(2027, 1).toUtc());
    expect(to.difference(from).inDays, 31);
    expect(to.difference(from).inDays, lessThan(62));
  });

  test('parses releases and sorts them by scheduled time', () async {
    final adapter = _FakeAdapter(
      '{"items":[${_release(id: 'b', scheduledAt: '2026-01-20T09:00:00Z')},'
      '${_release(id: 'a', scheduledAt: '2026-01-05T09:00:00Z')}]}',
    );
    final result = await ApiScheduleRepository(_dioWith(adapter))
        .month(DateTime(2026, 1));

    final releases = (result as Ok<List<Release>>).value;
    expect(releases.map((release) => release.id), ['a', 'b']);
    expect(releases.first.released, isTrue);
  });

  test('skips a malformed release but keeps the good ones', () async {
    final broken = _release().replaceFirst('"episodeSlug":"episode-slug",', '');
    final adapter = _FakeAdapter(
      '{"items":[$broken,${_release(id: 'good', title: 'Good')}]}',
    );
    final result = await ApiScheduleRepository(_dioWith(adapter))
        .month(DateTime(2026, 1));

    final releases = (result as Ok<List<Release>>).value;
    expect(releases, hasLength(1));
    expect(releases.single.title, 'Good');
  });

  test('an empty month is a successful empty list', () async {
    final adapter = _FakeAdapter('{"items":[]}');
    final result = await ApiScheduleRepository(_dioWith(adapter))
        .month(DateTime(2026, 1));

    expect((result as Ok<List<Release>>).value, isEmpty);
  });
}
