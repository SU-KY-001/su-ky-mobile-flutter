import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether a user is signed in, as `core`/`shared` code needs to know it.
/// The auth feature owns the session, so `main` overrides this provider with
/// a value derived from it (dependency inversion: `shared` never imports a
/// feature).
final signedInProvider = Provider<bool>(
  (ref) => throw UnimplementedError('signedInProvider must be overridden'),
);
