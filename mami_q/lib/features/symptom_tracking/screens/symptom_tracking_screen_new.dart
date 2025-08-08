import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/pregnancy_utils.dart';
import '../models/symptom_entry.dart';
import '../providers/symptom_tracking_provider_riverpod.dart';
import '../providers/providers.dart';

class SymptomTrackingScreen extends ConsumerStatefulWidget {
  const SymptomTrackingScreen({super.key});

  @override
  ConsumerState<SymptomTrackingScreen> createState() => _SymptomTrackingScreenState();
}

class _SymptomTrackingScreenState extends ConsumerState<SymptomTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load symptoms when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(symptomTrackingProvider.notifier).loadSymptoms();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final symptomState = ref.watch(symptomTrackingProvider);
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Symptom Tracking',
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.primary,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Today', icon: Icon(Icons.today)),
                Tab(text: 'History', icon: Icon(Icons.history)),
                Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
              ],
              indicatorColor: AppColors.white,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: () => _exportSymptoms(context),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => _showHelpDialog(context),
              ),
            ],
          ),
          body: symptomState.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: const [
                  TodayTab(),
                  HistoryTab(),
                  TrendsTab(),
                ],
              ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showSymptomEntryDialog(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: AppColors.white),
            label: const Text('Log Symptoms', style: TextStyle(color: AppColors.white)),
          ),
        );
      }
    );
  }

  void _showSymptomEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SymptomEntryDialog(),
    );
  }

  void _exportSymptoms(BuildContext context) {
    ref.read(symptomTrackingProvider.notifier).exportToPDF();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Symptoms exported successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Symptom Tracking Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Track your daily symptoms to monitor your health throughout pregnancy. '
                'Regular tracking helps identify patterns and can be valuable information '
                'to share with your healthcare provider.',
              ),
              SizedBox(height: 16),
              Text('Tips for effective tracking:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Log symptoms daily at the same time'),
              Text('• Be specific about severity levels'),
              Text('• Include photos for visual symptoms'),
              Text('• Note any triggers or relief methods'),
              Text('• Share reports with your doctor'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// Today Tab Widget
class TodayTab extends ConsumerWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptomState = ref.watch(symptomTrackingProvider);
    final todaySymptoms = symptomState.getTodaysSymptoms();
    final pregnancyWeek = PregnancyUtils.calculateCurrentWeek(DateTime.now().subtract(const Duration(days: 80)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPregnancyWeekCard(pregnancyWeek),
          const SizedBox(height: 16),
          _buildTodaysSummaryCard(todaySymptoms),
          const SizedBox(height: 16),
          _buildQuickSymptomLog(context, ref),
          const SizedBox(height: 16),
          _buildRecentEntries(todaySymptoms),
        ],
      ),
    );
  }

  Widget _buildPregnancyWeekCard(int week) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week $week',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            PregnancyUtils.getWeekDescription(week),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to log your symptoms for today',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysSummaryCard(List<SymptomEntry> symptoms) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Summary',
                style: AppTextStyles.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: symptoms.isEmpty ? AppColors.warning : AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  symptoms.isEmpty ? 'No entries' : '${symptoms.length} entries',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (symptoms.isEmpty)
            Text(
              'No symptoms logged today. How are you feeling?',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            )
          else
            Column(
              children: symptoms.take(3).map((symptom) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getSeverityColor(symptom.severity),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          symptom.title,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      Text(
                        'Severity: ${symptom.severity}/10',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickSymptomLog(BuildContext context, WidgetRef ref) {
    final quickSymptoms = ['Nausea', 'Fatigue', 'Back Pain', 'Mood Changes', 'Headache'];
    
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
            'Quick Log',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickSymptoms.map((symptom) {
              return GestureDetector(
                onTap: () => _quickLogSymptom(context, ref, symptom),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    symptom,
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries(List<SymptomEntry> symptoms) {
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
            'Recent Entries',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 12),
          if (symptoms.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No symptoms logged today',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: symptoms.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final symptom = symptoms[index];
                return SymptomEntryCard(symptom: symptom);
              },
            ),
        ],
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return AppColors.success;
    if (severity <= 6) return AppColors.warning;
    return AppColors.error;
  }

  void _quickLogSymptom(BuildContext context, WidgetRef ref, String symptomName) {
    // Show quick severity selection
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickSeveritySelector(
        symptomName: symptomName,
        onSeveritySelected: (severity) {
          ref.read(symptomTrackingProvider.notifier).addSymptom(
            SymptomEntry(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: 'current_user',
              date: DateTime.now(),
              title: symptomName,
              category: 'Physical',
              severity: severity,
              description: '',
              pregnancyWeek: PregnancyUtils.calculateCurrentWeek(
                DateTime.now().subtract(const Duration(days: 80)),
              ),
              symptoms: {},
              mood: 'Neutral',
              concerns: [],
              energyLevel: 5,
              sleepQuality: 5,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$symptomName logged with severity $severity'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }
}

// History Tab Widget
class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptomState = ref.watch(symptomTrackingProvider);
    final symptoms = symptomState.symptoms;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search symptoms...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(symptomTrackingProvider.notifier).searchSymptoms(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context, ref),
              ),
            ],
          ),
        ),
        Expanded(
          child: symptoms.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No symptom history yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start tracking your symptoms to see your history here',
                        style: TextStyle(color: AppColors.textTertiary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: symptoms.length,
                  itemBuilder: (context, index) {
                    final symptom = symptoms[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SymptomEntryCard(symptom: symptom),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Symptoms'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add filter options here
            const Text('Filter options coming soon...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Trends Tab Widget
class TrendsTab extends ConsumerWidget {
  const TrendsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptomState = ref.watch(symptomTrackingProvider);
    final symptoms = symptomState.symptoms;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklySummaryChart(symptoms),
          const SizedBox(height: 24),
          _buildSymptomFrequencyChart(symptoms),
          const SizedBox(height: 24),
          _buildSeverityTrendChart(symptoms),
          const SizedBox(height: 24),
          _buildInsightsCard(symptoms),
        ],
      ),
    );
  }

  Widget _buildWeeklySummaryChart(List<SymptomEntry> symptoms) {
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
            'Weekly Symptom Summary',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: symptoms.isEmpty
                ? const Center(child: Text('No data available'))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateWeeklySpots(symptoms),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 2,
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomFrequencyChart(List<SymptomEntry> symptoms) {
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
            'Most Common Symptoms',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: symptoms.isEmpty
                ? const Center(child: Text('No data available'))
                : PieChart(
                    PieChartData(
                      sections: _generateFrequencyData(symptoms),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityTrendChart(List<SymptomEntry> symptoms) {
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
            'Severity Trends',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: symptoms.isEmpty
                ? const Center(child: Text('No data available'))
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      barGroups: _generateSeverityData(symptoms),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(List<SymptomEntry> symptoms) {
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
            'Health Insights',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          if (symptoms.isEmpty)
            const Text('Start tracking symptoms to get personalized insights')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightItem(
                  'Total symptoms logged',
                  '${symptoms.length}',
                  Icons.assignment_turned_in,
                  AppColors.primary,
                ),
                const SizedBox(height: 12),
                _buildInsightItem(
                  'Average severity',
                  '${_calculateAverageSeverity(symptoms).toStringAsFixed(1)}/10',
                  Icons.trending_up,
                  AppColors.warning,
                ),
                const SizedBox(height: 12),
                _buildInsightItem(
                  'Most common symptom',
                  _getMostCommonSymptom(symptoms),
                  Icons.priority_high,
                  AppColors.error,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha:  0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              Text(
                value,
                style: AppTextStyles.titleSmall.copyWith(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<FlSpot> _generateWeeklySpots(List<SymptomEntry> symptoms) {
    // Generate spots for weekly chart
    final spots = <FlSpot>[];
    for (int i = 0; i < 7; i++) {
      final count = symptoms.where((s) => 
        s.date.weekday == i + 1
      ).length.toDouble();
      spots.add(FlSpot(i.toDouble(), count));
    }
    return spots;
  }

  List<PieChartSectionData> _generateFrequencyData(List<SymptomEntry> symptoms) {
    final frequency = <String, int>{};
    for (final symptom in symptoms) {
      frequency[symptom.title] = (frequency[symptom.title] ?? 0) + 1;
    }

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;
    
    frequency.entries.take(5).forEach((entry) {
      sections.add(
        PieChartSectionData(
          value: entry.value.toDouble(),
          title: entry.key,
          color: AppColors.chartColors[colorIndex % AppColors.chartColors.length],
          radius: 50,
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  List<BarChartGroupData> _generateSeverityData(List<SymptomEntry> symptoms) {
    final severityCount = <int, int>{};
    for (int i = 1; i <= 10; i++) {
      severityCount[i] = symptoms.where((s) => s.severity == i).length;
    }

    return severityCount.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: AppColors.primary,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  double _calculateAverageSeverity(List<SymptomEntry> symptoms) {
    if (symptoms.isEmpty) return 0;
    final total = symptoms.fold(0, (sum, symptom) => sum + symptom.severity);
    return total / symptoms.length;
  }

  String _getMostCommonSymptom(List<SymptomEntry> symptoms) {
    if (symptoms.isEmpty) return 'None';
    
    final frequency = <String, int>{};
    for (final symptom in symptoms) {
      frequency[symptom.title] = (frequency[symptom.title] ?? 0) + 1;
    }

    return frequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

// Symptom Entry Card Widget
class SymptomEntryCard extends StatelessWidget {
  final SymptomEntry symptom;

  const SymptomEntryCard({super.key, required this.symptom});

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  symptom.title,
                  style: AppTextStyles.titleSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(symptom.severity),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${symptom.severity}/10',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                PregnancyUtils.formatDateTime(symptom.date),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.category,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                symptom.category,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (symptom.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              symptom.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return AppColors.success;
    if (severity <= 6) return AppColors.warning;
    return AppColors.error;
  }
}

// Symptom Entry Dialog
class SymptomEntryDialog extends ConsumerStatefulWidget {
  const SymptomEntryDialog({super.key});

  @override
  ConsumerState<SymptomEntryDialog> createState() => _SymptomEntryDialogState();
}

class _SymptomEntryDialogState extends ConsumerState<SymptomEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = AppConstants.symptomCategories.first;
  int _severity = 5;
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Symptom',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Symptom Name',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a symptom name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: AppConstants.symptomCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Severity: $_severity/10',
                  style: AppTextStyles.labelLarge,
                ),
                Slider(
                  value: _severity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: _getSeverityColor(_severity),
                  onChanged: (value) {
                    setState(() {
                      _severity = value.round();
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedImage != null) ...[
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_selectedImage == null ? 'Add Photo' : 'Change Photo'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveSymptom,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveSymptom() {
    if (_formKey.currentState!.validate()) {
      final symptom = SymptomEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        date: DateTime.now(),
        title: _titleController.text.trim(),
        category: _selectedCategory,
        severity: _severity,
        description: _descriptionController.text.trim(),
        pregnancyWeek: PregnancyUtils.calculateCurrentWeek(
          DateTime.now().subtract(const Duration(days: 80)),
        ),
        // Store image path in images list instead of imageUrl
        images: _selectedImage != null ? [_selectedImage!.path] : null,
        symptoms: {},
        mood: 'Neutral',
        concerns: [],
        energyLevel: 5.0,
        sleepQuality: 5.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      ref.read(symptomTrackingProvider.notifier).addSymptom(symptom);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptom logged successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return AppColors.success;
    if (severity <= 6) return AppColors.warning;
    return AppColors.error;
  }
}

// Quick Severity Selector
class QuickSeveritySelector extends StatefulWidget {
  final String symptomName;
  final Function(int) onSeveritySelected;

  const QuickSeveritySelector({
    super.key,
    required this.symptomName,
    required this.onSeveritySelected,
  });

  @override
  State<QuickSeveritySelector> createState() => _QuickSeveritySelectorState();
}

class _QuickSeveritySelectorState extends State<QuickSeveritySelector> {
  int _selectedSeverity = 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How severe is your ${widget.symptomName.toLowerCase()}?',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            '$_selectedSeverity/10',
            style: AppTextStyles.headlineMedium.copyWith(
              color: _getSeverityColor(_selectedSeverity),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedSeverity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: _getSeverityColor(_selectedSeverity),
            onChanged: (value) {
              setState(() {
                _selectedSeverity = value.round();
              });
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSeveritySelected(_selectedSeverity),
              child: const Text('Log Symptom'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return AppColors.success;
    if (severity <= 6) return AppColors.warning;
    return AppColors.error;
  }
}

// Helper method to create a symptom entry correctly
SymptomEntry createSymptomEntry({
  required String id,
  required String userId,
  required DateTime date,
  required String symptomName,
  required double severity,
  required int pregnancyWeek,
  String? description,
  String category = 'Physical',
  List<String>? images,
  Map<String, dynamic>? symptoms,
  String? mood,
  List<String>? concerns,
  int? energyLevel,
  int? sleepQuality,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return SymptomEntry(
    id: id,
    userId: userId,
    date: date,
    title: symptomName,
    category: category,
    severity: severity.toInt(),
    description: description ?? '',
    pregnancyWeek: pregnancyWeek,
    images: images,
    symptoms: symptoms ?? {},
    mood: mood ?? 'Neutral',
    concerns: concerns ?? [],
    energyLevel: (energyLevel ?? 5).toDouble(),
    sleepQuality: (sleepQuality ?? 5).toDouble(),
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
  );
}
