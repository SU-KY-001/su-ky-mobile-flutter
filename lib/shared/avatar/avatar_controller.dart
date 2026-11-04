import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:su_ky_mobile/core/avatar/avatar_store.dart';

/// Local photo path for one account, shared by the Home avatar and profile.
class AvatarController extends Notifier<String?> {
  AvatarController(this.userId);

  final String userId;

  @override
  String? build() => ref.watch(avatarStoreProvider).read(userId);

  /// Opens the gallery and stores the result. Returns false when cancelled.
  Future<bool> pick() async {
    final store = ref.read(avatarStoreProvider);
    final picked = await store.pickFromGallery();
    if (picked == null) return false;
    final path = await store.persist(userId, picked);
    if (ref.mounted) state = path;
    return true;
  }

  Future<void> remove() async {
    await ref.read(avatarStoreProvider).clear(userId);
    if (ref.mounted) state = null;
  }
}

final avatarPathProvider =
    NotifierProvider.family<AvatarController, String?, String>(
      AvatarController.new,
    );
