import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Emergency contacts section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppColors.error.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Contacts',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildEmergencyContactCard(
                    'Emergency Ambulance',
                    '911',
                    Icons.local_hospital,
                  ),
                  const SizedBox(height: 12),
                  _buildEmergencyContactCard(
                    'Pregnancy Helpline',
                    '1-800-395-HELP',
                    Icons.pregnant_woman,
                  ),
                  const SizedBox(height: 12),
                  _buildEmergencyContactCard(
                    'Local Hospital',
                    'Add your hospital',
                    Icons.local_hospital,
                  ),
                ],
              ),
            ),
            
            // Warning signs section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warning Signs',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildWarningSignCard(
                      'Severe Abdominal Pain',
                      'Contact your healthcare provider immediately for severe or persistent pain',
                    ),
                    _buildWarningSignCard(
                      'Vaginal Bleeding',
                      'Any bleeding during pregnancy should be evaluated by your healthcare provider',
                    ),
                    _buildWarningSignCard(
                      'Severe Headache',
                      'Especially if accompanied by vision changes or swelling',
                    ),
                    _buildWarningSignCard(
                      'Decreased Fetal Movement',
                      'If you notice significantly reduced movement from your baby',
                    ),
                    _buildWarningSignCard(
                      'Contractions Before 37 Weeks',
                      'Regular, painful contractions before full term could indicate preterm labor',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Emergency call action
        },
        backgroundColor: AppColors.error,
        icon: const Icon(Icons.phone, color: Colors.white),
        label: const Text('Emergency Call', style: TextStyle(color: Colors.white)),
      ),
    );
  }
  
  Widget _buildEmergencyContactCard(String title, String number, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.error),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  Text(number, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: AppColors.error),
              onPressed: () {
                // Make phone call
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWarningSignCard(String title, String description) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
