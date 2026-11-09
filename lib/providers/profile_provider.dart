
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../repositories/profile_repository.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository =
      ProfileRepository(ProfileService());

  Profile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  // Mengambil data profil.
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
    } catch (e) {
      _errorMessage = 'Gagal mengambil data profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menyimpan perubahan profil.
  Future<bool> updateProfile(Profile updatedProfile) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProfile(updatedProfile);
      await loadProfile();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui profil: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Mengunggah dan menyimpan foto profil.
  Future<bool> updateProfilePhoto(File imageFile) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = await _repository.uploadProfilePhoto(imageFile);
      await _repository.updateAvatar(url);
      await loadProfile();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui foto profil: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
