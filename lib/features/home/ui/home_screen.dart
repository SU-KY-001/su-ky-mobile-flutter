import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/gen/app_localizations.dart';
import 'home_view_model.dart';

/// Reference View: renders ViewModel state, forwards events. Nothing else.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final taps = ref.watch(homeViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appName)),
      body: Center(child: Text(l10n.taps(taps))),
      floatingActionButton: FloatingActionButton(
        onPressed: ref.read(homeViewModelProvider.notifier).increment,
        tooltip: l10n.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
