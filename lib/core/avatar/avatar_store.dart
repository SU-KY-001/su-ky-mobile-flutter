import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/providers.dart';
import '../error/app_exception.dart';
import '../logging/app_logger.dart';

const _keyPrefix = 'profile.avatar.';
const _folder = 'avatars';
const _fileName = 'avatar.jpg';
const _ioTimeout = Duration(seconds: 10);

/// The account photo. No API hosts user uploads, so the picked image is copied
/// into app support storage and its path is kept per account in prefs.
abstract class AvatarStore {
  String? read(String userId);

  /// Picked image path, or null when the user backs out of the picker.
  Future<String?> pickFromGallery();
  Future<String> persist(String userId, String sourcePath);
  Future<void> clear(String userId);
}

class LocalAvatarStore implements AvatarStore {
  LocalAvatarStore(this._prefs, this._picker);

  final SharedPreferences _prefs;
  final ImagePicker _picker;

  @override
  String? read(String userId) {
    final key = '$_keyPrefix$userId';
    final path = _prefs.getString(key);
    if (path == null) return null;
    if (File(path).existsSync()) return path;
    unawaited(_prefs.remove(key));
    return null;
  }

  @override
  Future<String?> pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 85,
      );
      return file?.path;
    } on Object catch (error, stack) {
      AppLogger.error('Cannot pick avatar', error: error, stackTrace: stack);
      throw StorageException('Cannot pick avatar', cause: error);
    }
  }

  @override
  Future<String> persist(String userId, String sourcePath) async {
    try {
      final base = await getApplicationSupportDirectory().timeout(_ioTimeout);
      final folder = Directory('${base.path}/$_folder');
      await folder.create(recursive: true).timeout(_ioTimeout);
      final target = File('${folder.path}/${_safeName(userId)}');
      await File(sourcePath).copy(target.path).timeout(_ioTimeout);
      await _prefs.setString('$_keyPrefix$userId', target.path);
      return target.path;
    } on Object catch (error, stack) {
      AppLogger.error('Cannot save avatar', error: error, stackTrace: stack);
      throw StorageException('Cannot save avatar', cause: error);
    }
  }

  @override
  Future<void> clear(String userId) async {
    final path = _prefs.getString('$_keyPrefix$userId');
    await _prefs.remove('$_keyPrefix$userId');
    if (path == null) return;
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete().timeout(_ioTimeout);
    } on Object catch (error, stack) {
      AppLogger.error('Cannot delete avatar', error: error, stackTrace: stack);
    }
  }

  /// Account ids come from the API; keep the file name to safe characters.
  static String _safeName(String userId) =>
      '${userId.replaceAll(RegExp('[^A-Za-z0-9_-]'), '_')}_$_fileName';
}

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final avatarStoreProvider = Provider<AvatarStore>(
  (ref) => LocalAvatarStore(
    ref.watch(sharedPreferencesProvider),
    ref.watch(imagePickerProvider),
  ),
);
