
import 'dart:io';

import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository(this._profileService);

  Future<Profile> getProfile() async {
    final data = await _profileService.getProfile();
    return Profile.fromMap(data);
  }

  Future<void> updateProfile(Profile profile) async {
    await _profileService.updateProfile(profile.toMap());
  }

  Future<void> updateAvatar(String avatarUrl) async {
    await _profileService.updateProfile({
      'avatar_url': avatarUrl,
    });
  }

  Future<String> uploadProfilePhoto(File imageFile) async {
    return _profileService.uploadProfilePhoto(imageFile);
  }
}
