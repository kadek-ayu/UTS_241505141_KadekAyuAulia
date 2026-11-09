import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> submitFeedback({
    required String? customerId,
    required String? fullName,
    required int rating,
    required String message,
  }) async {
    await _client.from('feedback').insert({
      'customer_id': customerId,
      'full_name': fullName,
      'rating': rating,
      'message': message.trim(),
    });
  }
}