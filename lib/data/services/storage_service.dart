import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(
    String userId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final extension = path.extension(fileName);
      final ref = _storage.ref().child('users/$userId/profile$extension');

      final uploadTask = ref.putData(imageBytes);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
