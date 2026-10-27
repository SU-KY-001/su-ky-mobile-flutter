# AGENTS.md — test/

- Mirror `lib/` paths: `lib/a/b.dart` -> `test/a/b_test.dart`.
- Unit-test ViewModels, repositories, mappers, config parsing. Widget-test
  main flows. Integration tests (`integration_test/`) for DB/network
  boundaries with controlled fakes.
- Cover happy path + empty/null/boundary + error (retryable vs not).
- Meaningful assertions only; no tautologies, no testing framework wiring.
- Deterministic and isolated: no real network, clock, or shared DB state;
  inject fakes via constructors.
- Run: `flutter test` (all), `flutter test test/path_test.dart` (one).
