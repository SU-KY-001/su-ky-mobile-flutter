import 'package:flutter/material.dart';
import 'package:su_ky_mobile/core/auth/session_user.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _avatarRadius = 36.0;
const _headerGap = 16.0;

/// Spotify-style profile header: avatar left, name and email right, no card.
class ProfileUserHeader extends StatelessWidget {
  const ProfileUserHeader({super.key, required this.user});

  final SessionUser user;

  @override
  Widget build(BuildContext context) {
    final name = user.name.trim();
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Row(
      children: [
        CircleAvatar(
          radius: _avatarRadius,
          backgroundColor: AppDesign.tint,
          child: Text(
            initial,
            style: context.text.headlineSmall?.copyWith(
              color: context.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: _headerGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
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
      ],
    );
  }
}
