import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/meal_plan.dart';
import '../../providers/nutrition_provider.dart';

class NutritionTrackerTab extends ConsumerStatefulWidget {
  const NutritionTrackerTab({super.key});

  @override
  ConsumerState<NutritionTrackerTab> createState() => _NutritionTrackerTabState();
}

class _NutritionTrackerTabState extends ConsumerState<NutritionTrackerTab> {
  int _selectedTrimester = 1;
  String _selectedNutrient = 'Folic Acid';

  @override
  Widget build(BuildContext context) {
    final nutritionDataAsync = ref.watch(nutritionProgressProvider(_selectedTrimester));
    final requirements = PregnancyNutrition.getRequirementsForTrimester(_selectedTrimester);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrimesterSelector(),
          const SizedBox(height: 16),
          _buildNutrientSelector(requirements),
          const SizedBox(height: 24),
          
          Expanded(
            child: nutritionDataAsync.when(
              data: (nutritionData) => _buildNutritionContent(nutritionData, requirements),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error loading nutrition data',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrimesterSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 1; i <= 3; i++)
            ChoiceChip(
              label: Text('Trimester $i'),
              selected: _selectedTrimester == i,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTrimester = i;
                  });
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _selectedTrimester == i ? Colors.white : Colors.black,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNutrientSelector(List<NutritionalRequirement> requirements) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: requirements.map((req) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(req.nutrient),
              selected: _selectedNutrient == req.nutrient,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedNutrient = req.nutrient;
                  });
                }
              },
              selectedColor: req.isEssential 
                  ? AppColors.primary 
                  : AppColors.secondary,
              labelStyle: TextStyle(
                color: _selectedNutrient == req.nutrient ? Colors.white : Colors.black,
              ),
              avatar: req.isEssential 
                  ? const Icon(Icons.star, size: 16) 
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutritionContent(Map<String, double> nutritionData, List<NutritionalRequirement> requirements) {
    final selectedRequirement = requirements.firstWhere(
      (req) => req.nutrient == _selectedNutrient,
      orElse: () => requirements.first,
    );

    final currentValue = nutritionData[_selectedNutrient] ?? 0;
    final targetValue = selectedRequirement.dailyValue;
    final percentage = (currentValue / targetValue * 100).clamp(0, 100).toDouble();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(selectedRequirement, percentage, currentValue),
          const SizedBox(height: 24),
          _buildNutrientSourcesCard(selectedRequirement),
          const SizedBox(height: 24),
          _buildWeeklyProgressChart(selectedRequirement),
        ],
      ),
    );
  }

  Widget _buildProgressCard(NutritionalRequirement requirement, double percentage, double currentValue) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              requirement.nutrient,
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  height: 24,
                  width: MediaQuery.of(context).size.width * 0.8 * (percentage / 100),
                  decoration: BoxDecoration(
                    color: percentage < 50 ? AppColors.warning : AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentValue.toStringAsFixed(1)}/${requirement.dailyValue} ${requirement.unit}',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: percentage < 50 ? AppColors.warning : AppColors.success,
                  ),
                ),
              ],
            ),
            if (requirement.isEssential)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Essential for pregnancy',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientSourcesCard(NutritionalRequirement requirement) {
    final sources = _getNutrientSources(requirement.nutrient);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Sources for ${requirement.nutrient}',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sources.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.food_bank, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sources[index]['food']!,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            sources[index]['amount']!,
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart(NutritionalRequirement requirement) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Color(0xff67727d),
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            return Text(
                              days[index],
                              style: const TextStyle(
                                color: Color(0xff67727d),
                                fontSize: 10,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: requirement.dailyValue * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getMockDataPoints(requirement.dailyValue),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.secondary.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    LineChartBarData(
                      spots: List.generate(
                        7,
                        (index) => FlSpot(index.toDouble(), requirement.dailyValue),
                      ),
                      isCurved: false,
                      color: Colors.grey[400],
                      barWidth: 1,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Your intake',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Recommended daily value',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getMockDataPoints(double target) {
    // Generate random but realistic data points for the week
    final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000;
    return List.generate(7, (index) {
      return FlSpot(
        index.toDouble(),
        (target * (0.5 + (random + index / 10) % 0.8)).clamp(target * 0.3, target * 1.2),
      );
    });
  }

  List<Map<String, String>> _getNutrientSources(String nutrient) {
    switch (nutrient) {
      case 'Folic Acid':
        return [
          {'food': 'Spinach', 'amount': '1 cup (30g): 58.2 mcg'},
          {'food': 'Beans', 'amount': '1/2 cup (85g): 146 mcg'},
          {'food': 'Liver', 'amount': '3 ounces (85g): 215 mcg'},
          {'food': 'Oranges', 'amount': '1 medium: 39 mcg'},
          {'food': 'Fortified Cereals', 'amount': '3/4 cup: 100 mcg'},
        ];
      case 'Iron':
        return [
          {'food': 'Red Meat', 'amount': '3 ounces (85g): 2.1 mg'},
          {'food': 'Spinach', 'amount': '1 cup cooked: 6.4 mg'},
          {'food': 'Lentils', 'amount': '1 cup cooked: 6.6 mg'},
          {'food': 'Beans', 'amount': '1 cup cooked: 4.5 mg'},
          {'food': 'Fortified Cereals', 'amount': '3/4 cup: 18 mg'},
        ];
      case 'Calcium':
        return [
          {'food': 'Milk', 'amount': '1 cup (240ml): 300 mg'},
          {'food': 'Yogurt', 'amount': '1 cup (245g): 450 mg'},
          {'food': 'Cheese', 'amount': '1 ounce (28g): 200 mg'},
          {'food': 'Kale', 'amount': '1 cup cooked: 177 mg'},
          {'food': 'Fortified Orange Juice', 'amount': '1 cup: 350 mg'},
        ];
      case 'Protein':
        return [
          {'food': 'Chicken Breast', 'amount': '3 ounces (85g): 26g'},
          {'food': 'Fish', 'amount': '3 ounces (85g): 22g'},
          {'food': 'Beans', 'amount': '1 cup cooked: 15g'},
          {'food': 'Greek Yogurt', 'amount': '1 cup (245g): 23g'},
          {'food': 'Eggs', 'amount': '2 large: 12g'},
        ];
      default:
        return [
          {'food': 'Various Sources', 'amount': 'Consult your healthcare provider'},
        ];
    }
  }
}
