import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/symptom_entry.dart';
import '../providers/symptom_tracking_provider.dart';

class SymptomTrackingScreen extends StatefulWidget {
  const SymptomTrackingScreen({super.key});

  @override
  State<SymptomTrackingScreen> createState() => _SymptomTrackingScreenState();
}

class _SymptomTrackingScreenState extends State<SymptomTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize symptom tracking data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SymptomTrackingProvider>().initialize('current_user_id');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Symptom Tracking',
          style: AppTextStyles.headlineSmall,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Today', icon: Icon(Icons.today)),
            Tab(text: 'History', icon: Icon(Icons.history)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: Consumer<SymptomTrackingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.symptomEntries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTodayTab(provider),
              _buildHistoryTab(provider),
              _buildTrendsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodayTab(SymptomTrackingProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActionCards(provider),
          const SizedBox(height: 24),
          _buildTodayEntry(provider),
          const SizedBox(height: 24),
          _buildConcerningSymptoms(provider),
        ],
      ),
    );
  }

  Widget _buildQuickActionCards(SymptomTrackingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Log Symptoms',
                Icons.add_circle_outline,
                AppColors.primary,
                () => _showSymptomEntryDialog(provider),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'View Summary',
                Icons.analytics_outlined,
                AppColors.secondary,
                () => _tabController.animateTo(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayEntry(SymptomTrackingProvider provider) {
    final todayEntry = provider.todayEntry;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Entry',
              style: AppTextStyles.titleLarge,
            ),
            if (todayEntry != null)
              IconButton(
                onPressed: () => _showSymptomEntryDialog(provider, todayEntry),
                icon: const Icon(Icons.edit),
                color: AppColors.primary,
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (todayEntry == null)
          _buildEmptyTodayCard()
        else
          _buildTodayEntryCard(todayEntry),
      ],
    );
  }

  Widget _buildEmptyTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No symptoms logged today',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Log Symptoms" to record your daily symptoms',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayEntryCard(SymptomEntry entry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week ${entry.pregnancyWeek}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              _buildMoodChip(entry.mood),
            ],
          ),
          const SizedBox(height: 16),
          _buildWellbeingMetrics(entry),
          const SizedBox(height: 16),
          _buildSymptomsPreview(entry.symptoms),
          if (entry.concerns.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildConcernsPreview(entry.concerns),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodChip(String mood) {
    final moodColors = {
      'Happy': AppColors.success,
      'Sad': AppColors.warning,
      'Anxious': AppColors.error,
      'Excited': AppColors.accent,
      'Tired': AppColors.textSecondary,
      'Normal': AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (moodColors[mood] ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (moodColors[mood] ?? AppColors.primary).withOpacity(0.3),
        ),
      ),
      child: Text(
        mood,
        style: AppTextStyles.labelSmall.copyWith(
          color: moodColors[mood] ?? AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildWellbeingMetrics(SymptomEntry entry) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'Energy',
            entry.energyLevel,
            Icons.battery_charging_full,
            AppColors.accent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricItem(
            'Sleep',
            entry.sleepQuality,
            Icons.bedtime,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
          Text(
            '${value.toStringAsFixed(1)}/10',
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsPreview(Map<String, dynamic> symptoms) {
    if (symptoms.isEmpty) {
      return Text(
        'No symptoms recorded',
        style: AppTextStyles.bodySmall,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symptoms (${symptoms.length})',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: symptoms.keys.take(3).map((symptom) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                symptom,
                style: AppTextStyles.labelSmall,
              ),
            );
          }).toList(),
        ),
        if (symptoms.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${symptoms.length - 3} more',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConcernsPreview(List<String> concerns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              'Concerns',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...concerns.take(2).map((concern) => Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 2),
              child: Text(
                '• $concern',
                style: AppTextStyles.bodySmall,
              ),
            )),
        if (concerns.length > 2)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              '+${concerns.length - 2} more concerns',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConcerningSymptoms(SymptomTrackingProvider provider) {
    if (provider.concerningSymptoms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Health Alerts',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...provider.concerningSymptoms.map((symptom) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        symptom,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to emergency contact or healthcare provider
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Contact Healthcare Provider'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(SymptomTrackingProvider provider) {
    if (provider.symptomEntries.isEmpty) {
      return const Center(
        child: Text('No symptom entries found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.symptomEntries.length,
      itemBuilder: (context, index) {
        final entry = provider.symptomEntries[index];
        return _buildHistoryCard(entry, provider);
      },
    );
  }

  Widget _buildHistoryCard(SymptomEntry entry, SymptomTrackingProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                style: AppTextStyles.titleMedium,
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Edit'),
                    onTap: () => _showSymptomEntryDialog(provider, entry),
                  ),
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () => _confirmDelete(provider, entry.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Week ${entry.pregnancyWeek}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              _buildMoodChip(entry.mood),
            ],
          ),
          const SizedBox(height: 12),
          _buildWellbeingMetrics(entry),
          const SizedBox(height: 12),
          _buildSymptomsPreview(entry.symptoms),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(SymptomTrackingProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Trends',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildTrendsOverview(provider),
          const SizedBox(height: 24),
          _buildMostFrequentSymptoms(provider),
          const SizedBox(height: 24),
          _buildMoodDistribution(provider),
        ],
      ),
    );
  }

  Widget _buildTrendsOverview(SymptomTrackingProvider provider) {
    final wellbeing = provider.getAverageWellbeing();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week\'s Average',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Energy',
                  wellbeing['energy']!,
                  Icons.battery_charging_full,
                  AppColors.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'Sleep',
                  wellbeing['sleep']!,
                  Icons.bedtime,
                  AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMostFrequentSymptoms(SymptomTrackingProvider provider) {
    final symptoms = provider.getMostFrequentSymptoms();
    
    if (symptoms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most Frequent Symptoms',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          ...symptoms.asMap().entries.map((entry) {
            final index = entry.key;
            final symptom = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    symptom,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(SymptomTrackingProvider provider) {
    final moods = provider.getMoodDistribution();
    
    if (moods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution (Last 30 Days)',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          ...moods.entries.map((entry) {
            final mood = entry.key;
            final count = entry.value;
            final total = moods.values.reduce((a, b) => a + b);
            final percentage = (count / total * 100).round();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(mood, style: AppTextStyles.bodyMedium),
                      Text('$percentage%', style: AppTextStyles.labelMedium),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: count / total,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showSymptomEntryDialog(SymptomTrackingProvider provider, [SymptomEntry? entry]) {
    showDialog(
      context: context,
      builder: (context) => SymptomEntryDialog(
        entry: entry,
        onSave: (symptomEntry) async {
          if (entry == null) {
            await provider.saveSymptomEntry(symptomEntry);
          } else {
            await provider.updateSymptomEntry(symptomEntry);
          }
        },
      ),
    );
  }

  void _confirmDelete(SymptomTrackingProvider provider, String entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this symptom entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteSymptomEntry(entryId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Symptom Entry Dialog will be created in a separate file
class SymptomEntryDialog extends StatelessWidget {
  final SymptomEntry? entry;
  final Function(SymptomEntry) onSave;

  const SymptomEntryDialog({
    super.key,
    this.entry,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder for now - will be implemented in a separate file
    return AlertDialog(
      title: Text(entry == null ? 'Add Symptoms' : 'Edit Symptoms'),
      content: const Text('Symptom entry form will be implemented here'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Collect form data and create SymptomEntry
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
