import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/core/auth/session_user.dart';
import 'package:su_ky_mobile/shared/avatar/avatar_controller.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';

const _initialScale = 0.72;

/// Account photo when one was picked, otherwise the name initial. Used by both
/// the Home avatar button and the profile header so the photo stays in sync.
class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key, required this.user, this.radius = 16});

  final SessionUser user;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(avatarPathProvider(user.id));
    final name = user.name.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppDesign.tint,
      foregroundImage: path == null ? null : FileImage(File(path)),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: context.text.titleMedium?.copyWith(
          color: context.accent,
          fontWeight: FontWeight.w800,
          fontSize: radius * _initialScale,
        ),
      ),
    );
  }
}
