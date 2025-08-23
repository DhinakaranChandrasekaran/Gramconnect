import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/complaint_provider.dart';
import '../widgets/complaint_form.dart';

class NewComplaintScreen extends StatelessWidget {
  const NewComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Complaint'),
        elevation: 0,
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, child) {
          return const ComplaintForm();
        },
      ),
    );
  }
}