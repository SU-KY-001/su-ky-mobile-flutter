import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _statePadding = 24.0;

class CatalogLoading extends StatelessWidget {
  const CatalogLoading({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(_statePadding),
    child: Center(child: CircularProgressIndicator()),
  );
}

class CatalogError extends StatelessWidget {
  const CatalogError({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(_statePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error is NetworkException
                ? l.catalogErrorNetwork
                : l.catalogErrorGeneric,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(color: AppDesign.muted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: Text(l.catalogRetry)),
        ],
      ),
    );
  }
}

class CatalogEmpty extends StatelessWidget {
  const CatalogEmpty({super.key, required this.message, this.title});

  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(_statePadding),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title!,
            textAlign: TextAlign.center,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(color: AppDesign.muted),
        ),
      ],
    ),
  );
}

/// Renders loading, error (with retry) and empty states for an async value so
/// every catalog block handles all three the same way.
class CatalogAsyncView<T> extends StatelessWidget {
  const CatalogAsyncView({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
    required this.isEmpty,
    required this.emptyMessage,
    this.emptyTitle,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;
  final bool Function(T data) isEmpty;
  final String emptyMessage;
  final String? emptyTitle;

  @override
  Widget build(BuildContext context) => value.when(
    loading: () => const CatalogLoading(),
    error: (error, _) => CatalogError(error: error, onRetry: onRetry),
    data: (data) => isEmpty(data)
        ? CatalogEmpty(title: emptyTitle, message: emptyMessage)
        : builder(data),
  );
}
