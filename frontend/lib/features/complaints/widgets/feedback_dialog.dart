import 'package:flutter/material.dart';
import '../../../core/models/complaint_model.dart';
import '../../../core/theme/app_theme.dart';

class FeedbackDialog extends StatefulWidget {
  final ComplaintModel complaint;

  const FeedbackDialog({
    super.key,
    required this.complaint,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _feedbackController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Your Experience'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How satisfied are you with the resolution of your complaint?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Feedback Text
          TextField(
            controller: _feedbackController,
            decoration: const InputDecoration(
              labelText: 'Additional Comments (Optional)',
              hintText: 'Share your experience...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _rating > 0 ? () {
            Navigator.of(context).pop({
              'rating': _rating,
              'feedback': _feedbackController.text.trim(),
            });
          } : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}