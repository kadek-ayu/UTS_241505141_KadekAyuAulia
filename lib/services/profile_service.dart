
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String tableName = 'profiles';
  static const String bucketName = 'profile-photos';
  static const int profileId = 1;

  // Mengambil data profil dummy dengan ID 1.
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client
        .from(tableName)
        .select()
        .eq('id', profileId)
        .single();

    return response;
  }

  // Memperbarui informasi profil.
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _client.from(tableName).update({
      ...data,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', profileId);
  }

  // Mengunggah foto profil ke Supabase Storage.
  Future<String> uploadProfilePhoto(File imageFile) async {
    final extension = imageFile.path.split('.').last.toLowerCase();

    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'jpg' || 'jpeg' => 'image/jpeg',
      'jfif' => 'image/jpeg',
      _ => 'application/octet-stream',
    };

    final fileName =
        'profile_$profileId.${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _client.storage.from(bucketName).upload(
      fileName,
      imageFile,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: true,
      ),
    );

    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }
}
