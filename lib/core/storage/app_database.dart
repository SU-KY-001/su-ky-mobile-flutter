import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Offline store. Add tables to `tables:` and bump [schemaVersion] with a
/// migration step in the same change; never edit a shipped schema in place.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'su_ky'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
