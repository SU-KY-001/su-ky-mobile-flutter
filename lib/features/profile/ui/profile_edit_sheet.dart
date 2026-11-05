import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/core/auth/session_user.dart';
import 'package:su_ky_mobile/core/error/app_exception.dart';
import 'package:su_ky_mobile/core/error/result.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/avatar/avatar_controller.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/user_avatar.dart';

const _avatarRadius = 36.0;
const _avatarGap = 16.0;
const _nameMaxLength = 50;
const _sheetPadding = EdgeInsets.fromLTRB(24, 8, 24, 24);
const _handleWidth = 36.0;
const _handleHeight = 4.0;

/// Bottom sheet for the display name and the account photo. The photo applies
/// as soon as it is picked; the name saves on "Save".
Future<void> showProfileEditSheet(BuildContext context, SessionUser user) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProfileEditSheet(user: user),
    );

class ProfileEditSheet extends ConsumerStatefulWidget {
  const ProfileEditSheet({super.key, required this.user});

  final SessionUser user;

  @override
  ConsumerState<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.user.name,
  );
  bool _saving = false;
  bool _avatarBusy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty && !_saving;

  Future<void> _pickAvatar() async {
    if (_avatarBusy) return;
    setState(() => _avatarBusy = true);
    try {
      await ref.read(avatarPathProvider(widget.user.id).notifier).pick();
    } on AppException catch (error) {
      if (mounted) setState(() => _error = _messageFor(context, error));
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _avatarBusy = true);
    await ref.read(avatarPathProvider(widget.user.id).notifier).remove();
    if (mounted) setState(() => _avatarBusy = false);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref
        .read(sessionControllerProvider.notifier)
        .updateName(_name.text);
    if (!mounted) return;
    switch (result) {
      case Ok():
        Navigator.of(context).pop();
      case Err(:final error):
        setState(() {
          _saving = false;
          _error = _messageFor(context, error);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasPhoto = ref.watch(avatarPathProvider(widget.user.id)) != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: _sheetPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: _handleWidth,
                  height: _handleHeight,
                  decoration: BoxDecoration(
                    color: AppDesign.line,
                    borderRadius: BorderRadius.circular(_handleHeight),
                  ),
                ),
              ),
              const SizedBox(height: AppDesign.gap),
              Text(
                l.profileEditTitle,
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDesign.gap),
              Row(
                children: [
                  UserAvatar(user: widget.user, radius: _avatarRadius),
                  const SizedBox(width: _avatarGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: _avatarBusy ? null : _pickAvatar,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, AppDesign.tapTarget),
                          ),
                          child: Text(l.profileEditChangeAvatar),
                        ),
                        if (hasPhoto)
                          TextButton(
                            onPressed: _avatarBusy ? null : _removeAvatar,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, AppDesign.tapTarget),
                            ),
                            child: Text(l.profileEditRemoveAvatar),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDesign.gap),
              TextField(
                controller: _name,
                textInputAction: TextInputAction.done,
                maxLength: _nameMaxLength,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _canSave ? _save() : null,
                decoration: InputDecoration(
                  labelText: l.profileEditNameLabel,
                  hintText: l.profileEditNameHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppDesign.gap / 2),
                Text(
                  _error!,
                  style: context.text.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppDesign.gap),
              FilledButton(
                onPressed: _canSave ? _save : null,
                child: Text(l.profileEditSave),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Network failures are the common case; the message stays short and local.
  String _messageFor(BuildContext context, AppException error) {
    final l = AppLocalizations.of(context);
    return error is NetworkException
        ? l.profileEditOffline
        : l.profileEditFailed;
  }
}
