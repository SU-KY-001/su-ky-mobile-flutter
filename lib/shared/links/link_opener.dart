import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hands [uri] to the phone's default browser. Returns false when nothing
/// could open it, so callers can tell the user instead of failing silently.
typedef LinkOpener = Future<bool> Function(Uri uri);

const _launchTimeout = Duration(seconds: 5);

Future<bool> _openInBrowser(Uri uri) async {
  try {
    return await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    ).timeout(_launchTimeout);
  } on PlatformException {
    return false;
  } on TimeoutException {
    return false;
  }
}

/// Overridable in tests, which must not start a real browser.
final linkOpenerProvider = Provider<LinkOpener>((ref) => _openInBrowser);
