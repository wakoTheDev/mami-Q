import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildPregnancyInfoCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Account'),
              _buildSettingsItem('Personal Information', Icons.person),
              _buildSettingsItem('Healthcare Provider', Icons.local_hospital),
              _buildSettingsItem('Emergency Contacts', Icons.emergency),
              const Divider(),
              _buildSectionTitle('App Settings'),
              _buildSettingsItem('Notifications', Icons.notifications),
              _buildSettingsItem('Privacy', Icons.privacy_tip),
              _buildSettingsItem('Help & Support', Icons.help),
              const Divider(),
              _buildSettingsItem('Logout', Icons.logout, color: AppColors.error),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sarah Johnson',
            style: AppTextStyles.headlineSmall,
          ),
          Text(
            'sarah.johnson@example.com',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPregnancyInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pregnancy Information', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow('Due Date', 'October 15, 2025'),
            _buildInfoRow('Current Week', 'Week 24'),
            _buildInfoRow('Trimester', 'Second Trimester'),
            _buildInfoRow('Last Checkup', 'June 25, 2025'),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // Edit pregnancy info
                },
                child: const Text('Edit Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: AppTextStyles.titleMedium,
      ),
    );
  }
  
  Widget _buildSettingsItem(String title, IconData icon, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(
        title, 
        style: AppTextStyles.bodyLarge.copyWith(
          color: color ?? AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Navigate to specific setting
      },
    );
  }
}
