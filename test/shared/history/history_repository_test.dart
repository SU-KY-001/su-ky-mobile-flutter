import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/shared/history/data/history_repository.dart';
import 'package:su_ky_mobile/shared/history/domain/listening_history.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body, {this.statusCode = 200});

  final String body;
  final int statusCode;
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
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_FakeAdapter adapter) => Dio()..httpClientAdapter = adapter;

String _entry({
  String slug = 'khoi-nghia-lam-son',
  String title = 'Khoi nghia Lam Son',
  String series = 'Viet Nam thoi phong kien',
  bool available = true,
  String narrationId = '0f8fad5b-d9cb-469f-a165-70867728950e',
  num percent = 7.142857,
  bool isCompleted = false,
  String lastListenedAt = '2026-11-03T10:20:30.000Z',
}) =>
    '{"episode":{"slug":"$slug","title":"$title","available":$available,'
    '"series":{"slug":"series-slug","title":"$series"}},'
    '"lastListenedAt":"$lastListenedAt","lastNarrationId":"$narrationId",'
    '"lastPositionMs":12502,"percent":$percent,"isCompleted":$isCompleted}';

String _body(String items) =>
    '{"items":[$items],"page":1,"limit":10,"total":1}';

void main() {
  test('parses a decimal percent, rounding and clamping it', () async {
    final adapter = _FakeAdapter(
      _body(
        '${_entry(percent: 82.18)},${_entry(percent: 150)},'
        '${_entry(percent: -3)}',
      ),
    );
    final result = await ApiHistoryRepository(_dioWith(adapter)).recent();

    final history = (result as Ok<ListeningHistory>).value;
    expect(history.items.map((item) => item.percent), [82, 100, 0]);
    expect(history.items.first.progress, closeTo(0.82, 0.001));
    expect(history.total, 1);
    expect(history.items.first.lastListenedAt.isUtc, isTrue);
    expect(history.items.first.available, isTrue);
    expect(
      history.items.first.narrationId,
      '0f8fad5b-d9cb-469f-a165-70867728950e',
    );
  });

  test('sends the fixed first page with status all', () async {
    final adapter = _FakeAdapter(_body(_entry()));
    await ApiHistoryRepository(_dioWith(adapter)).recent();

    expect(adapter.lastRequest?.path, '/api/me/listening-history');
    expect(adapter.lastRequest?.queryParameters, {
      'page': 1,
      'limit': 10,
      'status': 'all',
    });
  });

  test('skips a malformed entry but keeps the good ones', () async {
    final broken = _entry().replaceFirst('"title":"Khoi nghia Lam Son",', '');
    final adapter = _FakeAdapter(_body('$broken,${_entry(title: 'Good')}'));
    final result = await ApiHistoryRepository(_dioWith(adapter)).recent();

    final history = (result as Ok<ListeningHistory>).value;
    expect(history.items, hasLength(1));
    expect(history.items.single.episodeTitle, 'Good');
  });

  test('a missing items list fails the whole request', () async {
    final adapter = _FakeAdapter('{"total":0}');
    final result = await ApiHistoryRepository(_dioWith(adapter)).recent();

    expect(result, isA<Err<ListeningHistory>>());
    expect((result as Err<ListeningHistory>).error, isA<UnknownException>());
  });

  test('an unauthorized response is an ApiException error', () async {
    final adapter = _FakeAdapter(
      '{"error_code":"AUTH_REQUIRED","message":"Sign in required"}',
      statusCode: 401,
    );
    final result = await ApiHistoryRepository(_dioWith(adapter)).recent();

    final error = (result as Err<ListeningHistory>).error;
    expect(error, isA<ApiException>());
    expect((error as ApiException).statusCode, 401);
  });

  test('an empty history is a successful empty list', () async {
    final adapter = _FakeAdapter('{"items":[],"page":1,"limit":10,"total":0}');
    final result = await ApiHistoryRepository(_dioWith(adapter)).recent();

    final history = (result as Ok<ListeningHistory>).value;
    expect(history.items, isEmpty);
    expect(history.total, 0);
  });
}
