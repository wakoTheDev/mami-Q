import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/healthcare_facility.dart';
import '../providers/facility_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
// import removed



class FacilityDetailScreen extends ConsumerWidget {
  final String facilityId;
  
  const FacilityDetailScreen({
    super.key, 
    required this.facilityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facilitiesAsync = ref.watch(healthcareFacilitiesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Facility Details', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: facilitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading facility details: $error',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
        data: (facilities) {
          final facility = facilities.firstWhere(
            (f) => f.id == facilityId,
            orElse: () => HealthcareFacility(
              id: 'not-found',
              name: 'Facility Not Found',
              type: 'Unknown',
              address: 'Address not available',
              city: 'Unknown',
              state: 'Unknown',
              zipCode: 'Unknown',
              // country parameter removed as it's not in the model
              phoneNumber: 'Unknown',
              email: '',
              website: '',
              latitude: 0,
              longitude: 0,
              services: const [],
              specialists: const [],
              rating: 0,
              // reviews parameter removed as it's not in the model
              description: 'This facility could not be found.',
              imageUrl: null,
              location: const GeoPoint(latitude: 0, longitude: 0),
              contactInfo: {},
              operatingHours: const {},
              workingHours: const <String>[],
              acceptedInsurance: const [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));

          if (facility.id == 'not-found') {
            return Center(
              child: Text(
                'Facility not found',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.error),
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image or Placeholder
                if (facility.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      facility.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    ),
                  )
                else
                  _buildImagePlaceholder(),
                  
                const SizedBox(height: 16),
                
                // Header & Basic Info
                Text(
                  facility.name,
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        facility.type,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (facility.rating > 0) ...[
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${facility.rating}',
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description
                if (facility.description!.isNotEmpty) ...[
                  Text(
                    'About',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    facility.description ?? 'No description available',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Address & Contact
                _buildInfoCard(
                  title: 'Contact & Location',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        icon: Icons.location_on,
                        text: '${facility.address}, ${facility.city}, ${facility.state} ${facility.zipCode}',
                        color: AppColors.primary,
                        onTap: () => _openMaps(facility),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.phone,
                        text: facility.phoneNumber,
                        color: AppColors.secondary,
                        onTap: () => _makePhoneCall(facility.phoneNumber),
                      ),
                      if (facility.email != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.email,
                          text: facility.email!,
                          color: AppColors.accent,
                          onTap: () => _sendEmail(facility.email!),
                        ),
                      ],
                      if (facility.website != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.language,
                          text: facility.website!,
                          color: AppColors.info,
                          onTap: () => _openUrl(facility.website!),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Services
                if (facility.services.isNotEmpty) ...[
                  Text(
                    'Services Offered',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: facility.services.map((service) => Chip(
                      label: Text(service),
                      backgroundColor: AppColors.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      labelStyle: AppTextStyles.bodySmall,
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Specialists
                if (facility.specialists.isNotEmpty) ...[
                  Text(
                    'Specialists',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...facility.specialists.map(
                    (specialist) => Card(
                      elevation: 0,
                      color: AppColors.surfaceVariant,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                specialist,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Operating Hours
                if (facility.operatingHours.isNotEmpty) ...[
                  Text(
                    'Operating Hours',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: AppColors.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: facility.operatingHours.entries
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        e.key,
                                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        e.value,
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Bottom Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openMaps(facility),
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(facility.phoneNumber),
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.business,
          size: 48,
          color: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({required String title, required Widget content}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon, 
    required String text, 
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: onTap != null ? color : AppColors.textSecondary,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
  
  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Appointment Request',
    );
    await launchUrl(launchUri);
  }
  
  Future<void> _openUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final Uri launchUri = Uri.parse(url);
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }
  
  Future<void> _openMaps(HealthcareFacility facility) async {
    await MapsLauncher.launchCoordinates(
      facility.latitude,
      facility.longitude,
      facility.name,
    );
  }
}
