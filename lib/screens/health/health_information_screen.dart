
import 'package:flutter/material.dart';

class HealthInformationScreen extends StatelessWidget {
  const HealthInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Kesehatan'),
      ),
      body: const Center(
        child: Text(
          'Informasi kesehatan akan tersedia di sini.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

