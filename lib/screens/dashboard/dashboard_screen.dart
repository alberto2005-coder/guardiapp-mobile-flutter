import 'package:flutter/material.dart';
import 'package:flutter_widgets_guardiapp/screens/dashboard/widgets/summary_card.dart';
import 'package:flutter_widgets_guardiapp/screens/dashboard/widgets/whos_in_card.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildBodyContent(context);
  }

  Widget _buildBodyContent(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.locale.languageCode;
    final name = appState.currentUserName;

    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final upcomingBirthdays = appState.students.where((s) {
      final dob = s.dateOfBirth;
      final birthdayThisYear = DateTime(now.year, dob.month, dob.day);
      final birthdayNextYear = DateTime(now.year + 1, dob.month, dob.day);

      return (birthdayThisYear.isAfter(now) &&
              birthdayThisYear.isBefore(nextWeek)) ||
          (birthdayNextYear.isAfter(now) &&
              birthdayNextYear.isBefore(nextWeek));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.get(lang, 'hello')}, $name 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // Button removed
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SummaryCard(
                title: AppStrings.get(lang, 'total_teachers'),
                value: '${appState.totalTeachers}',
                icon: Icons.people,
                iconColor: const Color(0xFF6C63FF),
                backgroundColor: const Color(0xFFEBE9FF),
                onTapDetails: () => context.read<AppState>().setTabIndex(2),
                onTapRefresh: () => context.read<AppState>().hardReset(),
              ),
              const SizedBox(width: 16),
              SummaryCard(
                title: AppStrings.get(lang, 'on_leave'),
                value: '${appState.teachersOnLeave}',
                icon: Icons.beach_access,
                iconColor: const Color(0xFFFF9F1C),
                backgroundColor: const Color(0xFFFFF2D9),
                onTapDetails: () => context.read<AppState>().setTabIndex(4),
                onTapRefresh: () => context.read<AppState>().hardReset(),
              ),
              const SizedBox(width: 16),
              SummaryCard(
                title: AppStrings.get(lang, 'available'),
                value: '${appState.teachersAvailable}',
                icon: Icons.check_circle,
                iconColor: const Color(0xFF2EC4B6),
                backgroundColor: const Color(0xFFDBF7F4),
                onTapDetails: () => context.read<AppState>().setTabIndex(2),
                onTapRefresh: () => context.read<AppState>().hardReset(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 2, child: WhosInCard()),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.cake, size: 48, color: Colors.pink.shade300),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.get(lang, 'upcoming_birthdays'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${upcomingBirthdays.length} ${AppStrings.get(lang, 'birthdays_this_week')}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (upcomingBirthdays.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: upcomingBirthdays.length,
                            itemBuilder: (context, index) {
                              final s = upcomingBirthdays[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  "${s.name} (${s.dateOfBirth.day}/${s.dateOfBirth.month})",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        const Spacer(),
                        const Text(
                          "-",
                          style: TextStyle(fontSize: 24, color: Colors.grey),
                        ),
                        const Spacer(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
