import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserModel user;

  const ProfileInfoCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              context,
              'Full Name',
              user.fullName,
              Icons.person,
            ),

            const Divider(),

            if (user.email != null) ...[
              _buildInfoRow(
                context,
                'Email',
                user.email!,
                Icons.email,
              ),
              const Divider(),
            ],

            if (user.phoneNumber != null) ...[
              _buildInfoRow(
                context,
                'Phone Number',
                user.phoneNumber!,
                Icons.phone,
              ),
              const Divider(),
            ],

            _buildInfoRow(
              context,
              'Village',
              user.village,
              Icons.location_city,
            ),

            if (user.ward != null) ...[
              const Divider(),
              _buildInfoRow(
                context,
                'Ward',
                user.ward!,
                Icons.map,
              ),
            ],

            const Divider(),

            _buildInfoRow(
              context,
              'Member Since',
              _formatDate(user.createdAt),
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}