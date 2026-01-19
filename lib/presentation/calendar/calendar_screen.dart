import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/presentation/prayer/prayer_provider.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  // Calculate upcoming Islamic events based on current Hijri month
  List<Map<String, dynamic>> _calculateUpcomingEvents(
    int currentMonth,
    int currentDay,
    int currentYear,
  ) {
    // Islamic months: 1=Muharram, 2=Safar, 3=Rabi al-Awwal, 4=Rabi al-Thani,
    // 5=Jumada al-Awwal, 6=Jumada al-Thani, 7=Rajab, 8=Sha'ban,
    // 9=Ramadan, 10=Shawwal, 11=Dhul Qi'dah, 12=Dhul Hijjah

    final allEvents = [
      {
        'name': 'Ashura',
        'month': 1,
        'day': 10,
        'description': 'Day of Fasting',
      },
      {
        'name': 'Milad un Nabi ﷺ',
        'month': 3,
        'day': 12,
        'description': 'Birth of Prophet Muhammad ﷺ',
      },
      {
        'name': 'Isra and Mi\'raj',
        'month': 7,
        'day': 27,
        'description': 'Night Journey',
      },
      {
        'name': 'Shab e Barat',
        'month': 8,
        'day': 15,
        'description': 'Night of Forgiveness',
      },
      {
        'name': 'Ramadan Begins',
        'month': 9,
        'day': 1,
        'description': 'First day of fasting',
      },
      {
        'name': 'Laylat al-Qadr',
        'month': 9,
        'day': 27,
        'description': 'Night of Power',
      },
      {
        'name': 'Eid al-Fitr',
        'month': 10,
        'day': 1,
        'description': 'Festival of Breaking Fast',
      },
      {
        'name': 'Day of Arafah',
        'month': 12,
        'day': 9,
        'description': 'Day before Eid al-Adha',
      },
      {
        'name': 'Eid al-Adha',
        'month': 12,
        'day': 10,
        'description': 'Festival of Sacrifice',
      },
    ];

    // Filter events that are upcoming (current or future in current year)
    final upcoming = <Map<String, dynamic>>[];

    for (final event in allEvents) {
      final eventMonth = event['month'] as int;
      final eventDay = event['day'] as int;

      // Calculate days until event
      int daysUntil = 0;
      if (eventMonth > currentMonth ||
          (eventMonth == currentMonth && eventDay >= currentDay)) {
        // Event is in current year
        daysUntil = _calculateDaysInHijri(
          currentMonth,
          currentDay,
          eventMonth,
          eventDay,
        );
      } else {
        // Event is next year
        daysUntil =
            _calculateDaysInHijri(currentMonth, currentDay, 12, 30) +
            _calculateDaysInHijri(1, 1, eventMonth, eventDay);
      }

      upcoming.add({
        ...event,
        'daysUntil': daysUntil,
        'year': eventMonth >= currentMonth ? currentYear : currentYear + 1,
      });
    }

    // Sort by days until event
    upcoming.sort(
      (a, b) => (a['daysUntil'] as int).compareTo(b['daysUntil'] as int),
    );

    return upcoming.take(5).toList();
  }

  int _calculateDaysInHijri(
    int fromMonth,
    int fromDay,
    int toMonth,
    int toDay,
  ) {
    // Simplified calculation - each Hijri month ~29.5 days
    int days = 0;
    for (int m = fromMonth; m < toMonth; m++) {
      days += (m % 2 == 1) ? 30 : 29; // Alternating 30/29 days
    }
    days += (toDay - fromDay);
    return days.abs();
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhul Qi\'dah',
      'Dhul Hijjah',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hijriDateAsync = ref.watch(hijriDateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Calendar'), centerTitle: true),
      body: hijriDateAsync.when(
        data: (hijri) {
          final day = hijri['day'] as String? ?? '1';
          final month = hijri['month'] as Map<String, dynamic>? ?? {};
          final monthEn = month['en'] as String? ?? 'Unknown';
          final monthNumber = month['number'] as int? ?? 1;
          final year = hijri['year'] as String? ?? '1446';
          final designation =
              (hijri['designation'] as Map<String, dynamic>?)?['abbreviated'] ??
              'AH';

          final upcomingEvents = _calculateUpcomingEvents(
            monthNumber,
            int.tryParse(day) ?? 1,
            int.tryParse(year) ?? 1446,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Main Hijri Date Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: AppColors.goldTileGradient,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mosque,
                          size: 40,
                          color: Colors.black54,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          day,
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '$monthEn $year $designation',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatGregorianDate(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade().scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                ),

                const SizedBox(height: 32),

                // Upcoming Events Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${upcomingEvents.length} events',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Events List
                ...upcomingEvents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  final daysUntil = event['daysUntil'] as int;

                  return _EventCard(
                    title: event['name'] as String,
                    description: event['description'] as String,
                    hijriDate:
                        '${event['day']} ${_getMonthName(event['month'] as int)}',
                    daysUntil: daysUntil,
                    isToday: daysUntil == 0,
                    index: index,
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryGold),
              SizedBox(height: 16),
              Text('Loading calendar...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(hijriDateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatGregorianDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d, y').format(now);
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String hijriDate;
  final int daysUntil;
  final bool isToday;
  final int index;

  const _EventCard({
    required this.title,
    required this.description,
    required this.hijriDate,
    required this.daysUntil,
    required this.isToday,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primaryGold.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? AppColors.primaryGold
              : Colors.grey.withValues(alpha: 0.2),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Event icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primaryGold
                    : AppColors.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event,
                color: isToday ? Colors.black : AppColors.primaryGold,
              ),
            ),
            const SizedBox(width: 16),
            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hijriDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: daysUntil <= 7
                              ? Colors.orange.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          daysUntil == 0
                              ? 'Today!'
                              : daysUntil == 1
                              ? 'Tomorrow'
                              : 'In $daysUntil days',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: daysUntil <= 7
                                ? Colors.orange
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade().slideX(
      begin: 0.03,
      end: 0,
      delay: Duration(milliseconds: index * 100),
    );
  }
}
