import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';
import '../../services/feedback_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _service = FeedbackService();

  int _rating = 0;
  bool _isSubmitting = false;

  static const Color primaryColor = Color(0xFF7653B5);

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String? _validateMessage(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Feedback wajib diisi.';
    }

    if (text.length < 2) {
      return 'Feedback minimal terdiri dari 2 karakter.';
    }

    if (RegExp(r'^[0-9]+$').hasMatch(text)) {
      return 'Feedback tidak boleh hanya berisi angka.';
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(text)) {
      return 'Feedback harus mengandung huruf.';
    }

    return null;
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih rating terlebih dahulu.'),
        ),
      );
      return;
    }

    final profile = context.read<ProfileProvider>().profile;

    setState(() => _isSubmitting = true);

    try {
      await _service.submitFeedback(
        customerId: profile?.customerId,
        fullName: profile?.fullName,
        rating: _rating,
        message: _messageController.text,
      );

      if (!mounted) return;

      _messageController.clear();

      setState(() {
        _rating = 0;
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih! Feedback berhasil dikirim.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      appBar: AppBar(
        title: const Text(
          'Feedback ApoTech',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 65,
              color: primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Berikan Feedback Anda!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bagaimana pengalaman Anda menggunakan aplikasi ApoTech? '
              'Masukan Anda membantu kami meningkatkan kualitas aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 28),
            const Text(
              'Berikan Penilaian',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final selected = index < _rating;

                return IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => setState(() => _rating = index + 1),
                  icon: Icon(
                    selected ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                );
              }),
            ),
            Center(
              child: Text(
                _rating == 0
                    ? 'Belum ada penilaian'
                    : '$_rating dari 5 bintang',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tulis Feedback Anda',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              maxLength: 500,
              validator: _validateMessage,
              decoration: InputDecoration(
                hintText: 'Tuliskan kritik, saran, atau pengalaman Anda...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Mengirim...' : 'Kirim Feedback',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}