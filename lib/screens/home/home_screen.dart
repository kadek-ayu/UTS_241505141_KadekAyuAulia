
import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../health/health_information_screen.dart';
import '../medicines/medicine_list_screen.dart';
import '../medicines/favorite_screen.dart';
import '../pharmacies/pharmacy_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.emergency,
            color: Colors.red,
            size: 38,
          ),
          title: const Text('SOS Darurat'),
          content: const Text(
            'Fitur ini digunakan untuk informasi bantuan '
            'darurat rumah sakit.\n\n'
            'Pastikan nomor tujuan telah diverifikasi '
            'sebelum melakukan panggilan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Nomor layanan darurat belum dikonfigurasi.',
                    ),
                  ),
                );
              },
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_pharmacy_outlined),
            SizedBox(width: 8),
            Text(
              'ApoTech',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),

            const SizedBox(height: 28),

            const Text(
              'Jelajahi ApoTech',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildMenuCard(
                  title: 'Katalog Obat',
                  description: 'Informasi obat dari OpenFDA',
                  icon: Icons.medication_outlined,
                  color: AppTheme.blueAccent,
                  onTap: () => _openPage(
                    context,
                    const MedicineListScreen(),
                  ),
                ),
                _buildMenuCard(
                  title: 'Produk Tersimpan',
                  description: 'Lihat obat favorit kamu',
                  icon: Icons.bookmark_outline,
                  color: AppTheme.paleYellow,
                  onTap: () => _openPage(
                    context,
                    const FavoriteScreen(),
                  ),
                ),
                _buildMenuCard(
                  title: 'Apotek Terdekat',
                  description: 'Informasi apotek terdaftar',
                  icon: Icons.store_outlined,
                  color: AppTheme.blueAccent,
                  onTap: () => _openPage(
                    context,
                    const PharmacyListScreen(),
                  ),
                ),
                _buildMenuCard(
                  title: 'SOS Darurat',
                  description: 'Informasi bantuan darurat',
                  icon: Icons.emergency,
                  color: const Color(0xFFFFE1E1),
                  iconColor: Colors.red,
                  onTap: () => _showEmergencyDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Temukan Informasi Kesehatan',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            InkWell(
              onTap: () => _openPage(
                context,
                const HealthInformationScreen(),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      color: Colors.white,
                      size: 34,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Kesehatan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Temukan informasi kesehatan di sekitar Anda.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.blueAccent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang di ApoTech!',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Temukan informasi obat dan produk '
            'kesehatan dengan mudah melalui ApoTech.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    Color iconColor = AppTheme.primaryColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: iconColor,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
