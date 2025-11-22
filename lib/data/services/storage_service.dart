import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final extension = path.extension(imageFile.path);
      final ref = _storage.ref().child('users/$userId/profile$extension');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
