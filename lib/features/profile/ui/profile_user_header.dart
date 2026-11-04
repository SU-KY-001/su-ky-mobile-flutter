import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:su_ky_mobile/core/auth/session_user.dart';
import 'package:su_ky_mobile/features/profile/ui/profile_edit_sheet.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/user_avatar.dart';

const _avatarRadius = 36.0;
const _headerGap = 16.0;
const _badgePadding = 5.0;
const _badgeIcon = 14.0;

/// Spotify-style profile header: avatar left, name and email right, no card.
/// Tapping it opens the edit sheet.
class ProfileUserHeader extends StatelessWidget {
  const ProfileUserHeader({super.key, required this.user});

  final SessionUser user;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return InkWell(
      onTap: () => showProfileEditSheet(context, user),
      borderRadius: BorderRadius.circular(AppDesign.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(user: user, radius: _avatarRadius),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Tooltip(
                    message: l.profileEditTitle,
                    child: Container(
                      padding: const EdgeInsets.all(_badgePadding),
                      decoration: const BoxDecoration(
                        color: AppDesign.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Symbols.photo_camera,
                        size: _badgeIcon,
                        color: context.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: _headerGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      color: AppDesign.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Symbols.chevron_right, color: AppDesign.muted),
          ],
        ),
      ),
    );
  }
}
