import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:su_ky_mobile/core/config/app_config.dart';
import 'package:su_ky_mobile/core/network/dio_factory.dart';
import 'package:su_ky_mobile/core/storage/token_store.dart';

/// One canned HTTP answer. [throwType] simulates a transport failure.
class StubReply {
  const StubReply(
    this.status,
    this.body, {
    this.headers = const {},
    this.throwType,
  });

  final int status;
  final Object? body;
  final Map<String, String> headers;
  final DioExceptionType? throwType;
}

typedef StubHandler = FutureOr<StubReply> Function(RequestOptions options);

/// Serves [handler] answers and records every request. No network.
class StubAdapter implements HttpClientAdapter {
  StubAdapter(this.handler);

  final StubHandler handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final reply = await handler(options);
    if (reply.throwType != null) {
      throw DioException(requestOptions: options, type: reply.throwType!);
    }
    final text = reply.body is String ? reply.body! : jsonEncode(reply.body);
    return ResponseBody.fromString(
      text as String,
      reply.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        for (final e in reply.headers.entries) e.key: [e.value],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

final testConfig = AppConfig(
  environment: AppEnvironment.dev,
  apiBaseUrl: Uri.parse('https://api.test'),
);

/// App Dio (interceptors and error mapping included) over [handler].
(Dio, StubAdapter) stubDio(StubHandler handler, {TokenStore? tokens}) {
  final adapter = StubAdapter(handler);
  final dio = createDio(testConfig, tokens: tokens)
    ..httpClientAdapter = adapter;
  return (dio, adapter);
}
