import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/presentation/prayer/prayer_tracker_provider.dart';
import 'package:islamic_app/data/repositories/prayer_tracker_repository.dart';

/// Prayer Tracker History Screen - Monthly Calendar View
class PrayerTrackerHistoryScreen extends ConsumerStatefulWidget {
  const PrayerTrackerHistoryScreen({super.key});

  @override
  ConsumerState<PrayerTrackerHistoryScreen> createState() =>
      _PrayerTrackerHistoryScreenState();
}

class _PrayerTrackerHistoryScreenState
    extends ConsumerState<PrayerTrackerHistoryScreen> {
  late DateTime _selectedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(
      monthlyPrayerHistoryProvider((
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      )),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer History'), centerTitle: true),
      body: Column(
        children: [
          // Month Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _getMonthYearText(_selectedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed:
                      _selectedMonth.month < DateTime.now().month ||
                          _selectedMonth.year < DateTime.now().year
                      ? _nextMonth
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ).animate().fade(),

          // Calendar Grid
          Expanded(
            child: historyAsync.when(
              data: (history) => _buildCalendar(context, history, isDark),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),

          // Selected Date Details
          if (_selectedDate != null) ...[_buildSelectedDateDetails(isDark)],
        ],
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    List<PrayerTrackingData> history,
    bool isDark,
  ) {
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    final firstDayOfWeek =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;

    // Create map for quick lookup
    final historyMap = <String, PrayerTrackingData>{};
    for (final data in history) {
      historyMap[data.date] = data;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekday Headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + firstDayOfWeek,
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek) {
                return const SizedBox();
              }

              final day = index - firstDayOfWeek + 1;
              final date = DateTime(
                _selectedMonth.year,
                _selectedMonth.month,
                day,
              );
              final dateStr =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final dayData = historyMap[dateStr];
              final completedCount = dayData?.completedCount ?? 0;
              final isToday = _isToday(date);
              final isSelected =
                  _selectedDate != null &&
                  date.year == _selectedDate!.year &&
                  date.month == _selectedDate!.month &&
                  date.day == _selectedDate!.day;
              final isFuture = date.isAfter(DateTime.now());

              return GestureDetector(
                onTap: isFuture
                    ? null
                    : () {
                        setState(() => _selectedDate = date);
                      },
                child:
                    Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGold
                                : _getCompletionColor(
                                    completedCount,
                                    isDark,
                                    isFuture,
                                  ),
                            borderRadius: BorderRadius.circular(10),
                            border: isToday
                                ? Border.all(
                                    color: AppColors.primaryGold,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  day.toString(),
                                  style: TextStyle(
                                    fontWeight: isToday || isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.black
                                        : isFuture
                                        ? Colors.grey
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                    fontSize: 14,
                                  ),
                                ),
                                if (!isFuture && completedCount > 0)
                                  Text(
                                    '$completedCount/5',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isSelected
                                          ? Colors.black54
                                          : (isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600]),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                        .animate(delay: (index * 10).ms)
                        .fade()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                        ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Legend
          _buildLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('0', Colors.transparent, isDark),
          _buildLegendItem('1-2', Colors.orange.withValues(alpha: 0.3), isDark),
          _buildLegendItem('3-4', Colors.green.withValues(alpha: 0.3), isDark),
          _buildLegendItem('5', Colors.green.withValues(alpha: 0.6), isDark),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: color == Colors.transparent
                ? Border.all(color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDateDetails(bool isDark) {
    final dateStr =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    return FutureBuilder<PrayerTrackingData>(
      future: ref
          .read(prayerTrackerRepositoryProvider)
          .getTrackingForDate(dateStr),
      builder: (context, snapshot) {
        final data = snapshot.data;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDate(_selectedDate!),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPrayerChip('Fajr', data?.fajr ?? false),
                  _buildPrayerChip('Dhuhr', data?.dhuhr ?? false),
                  _buildPrayerChip('Asr', data?.asr ?? false),
                  _buildPrayerChip('Maghrib', data?.maghrib ?? false),
                  _buildPrayerChip('Isha', data?.isha ?? false),
                ],
              ),
            ],
          ),
        ).animate().fade().slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildPrayerChip(String name, bool completed) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: completed ? Colors.green : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : Icons.close,
            color: completed ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Color _getCompletionColor(int count, bool isDark, bool isFuture) {
    if (isFuture) return isDark ? Colors.grey[850]! : Colors.grey[200]!;
    if (count == 0) return isDark ? Colors.grey[800]! : Colors.grey[100]!;
    if (count <= 2) return Colors.orange.withValues(alpha: 0.3);
    if (count <= 4) return Colors.green.withValues(alpha: 0.3);
    return Colors.green.withValues(alpha: 0.6);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getMonthYearText(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }
}
