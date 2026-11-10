
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final double indicatorSize;

  const LoadingWidget({
    super.key,
    this.message = 'Memuat data...',
    this.indicatorSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
