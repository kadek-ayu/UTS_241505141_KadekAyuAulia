
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/profile.dart';
import '../../providers/profile_provider.dart';

const Color primaryColor = Color(0xFF7653B5);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  File? _selectedImage;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final profile = context.read<ProfileProvider>().profile;

      if (profile != null) {
        _nameController.text = profile.fullName;
        _phoneController.text = profile.phoneNumber;
        _emailController.text = profile.email ?? '';
        _addressController.text = profile.address ?? '';
      }

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final currentProfile = provider.profile;

    if (currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data profil belum tersedia.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedProfile = Profile(
      id: currentProfile.id,
      customerId: currentProfile.customerId,
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      createdAt: currentProfile.createdAt,
      updatedAt: DateTime.now(),
      avatarUrl: currentProfile.avatarUrl,
    );

    final profileSaved = await provider.updateProfile(updatedProfile);

    if (!mounted) return;

    if (!profileSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Gagal menyimpan perubahan profil.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedImage != null) {
      final photoSaved =
          await provider.updateProfilePhoto(_selectedImage!);

      if (!mounted) return;

      if (!photoSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ??
                  'Profil tersimpan, tetapi foto gagal diperbarui.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui.'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: primaryColor),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final profile = provider.profile;

        if (profile == null && provider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Profil')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Profil')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Data profil tidak dapat dimuat.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.loadProfile,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7FA),
          appBar: AppBar(
            title: const Text(
              'Edit Profil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor:
                                  primaryColor.withValues(alpha: 0.12),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (profile.avatarUrl != null &&
                                          profile.avatarUrl!.isNotEmpty
                                      ? NetworkImage(profile.avatarUrl!)
                                      : null) as ImageProvider?,
                              child: _selectedImage == null &&
                                      (profile.avatarUrl == null ||
                                          profile.avatarUrl!.isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      size: 55,
                                      color: primaryColor,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text(
                            'Ubah Foto Profil',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Informasi Pribadi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    label: 'Nama Lengkap',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hint: 'Masukkan nama lengkap',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama lengkap wajib diisi.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    label: 'Nomor Telepon',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hint: 'Masukkan nomor telepon',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final phone = value?.trim() ?? '';

                      if (phone.isEmpty) {
                        return 'Nomor telepon wajib diisi.';
                      }

                      if (!RegExp(r'^[0-9+]+$').hasMatch(phone)) {
                        return 'Nomor telepon hanya boleh berisi angka dan +.';
                      }

                      if (phone.length < 8) {
                        return 'Nomor telepon minimal 8 karakter.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hint: 'Masukkan alamat email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isNotEmpty &&
                          !RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email)) {
                        return 'Format email tidak valid.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    label: 'Alamat',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                    hint: 'Masukkan alamat',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isSaving ? null : _saveProfile,
                      icon: provider.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        provider.isSaving
                            ? 'Menyimpan...'
                            : 'Simpan Perubahan',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
