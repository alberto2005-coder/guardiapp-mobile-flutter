import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';
import 'package:flutter_widgets_guardiapp/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_widgets_guardiapp/screens/schedule/schedule_screen.dart';
import 'package:flutter_widgets_guardiapp/screens/absences/absences_screen.dart';
import 'package:flutter_widgets_guardiapp/screens/teachers/teachers_screen.dart';
import 'package:flutter_widgets_guardiapp/screens/students/students_screen.dart';
import 'package:flutter_widgets_guardiapp/screens/settings/settings_screen.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedIndex = appState.selectedTabIndex;

    return Scaffold(
      body: Container(
        decoration: appState.currentBackgroundPath != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: appState.currentBackgroundPath!.startsWith('assets/')
                      ? AssetImage(appState.currentBackgroundPath!)
                            as ImageProvider
                      : FileImage(File(appState.currentBackgroundPath!)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2),
                    BlendMode.darken,
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (int index) {
                context.read<AppState>().setTabIndex(index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: Text(
                    AppStrings.get(
                      context.read<AppState>().locale.languageCode,
                      'dashboard',
                    ),
                  ),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.calendar_month_outlined),
                  selectedIcon: const Icon(Icons.calendar_month),
                  label: Text(
                    AppStrings.get(
                      context.read<AppState>().locale.languageCode,
                      'schedule',
                    ),
                  ),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.people_alt_outlined),
                  selectedIcon: const Icon(Icons.people_alt),
                  label: Text(
                    AppStrings.get(
                      context.read<AppState>().locale.languageCode,
                      'teachers',
                    ),
                  ),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.school_outlined),
                  selectedIcon: const Icon(Icons.school),
                  label: Text(
                    AppStrings.get(
                      context.read<AppState>().locale.languageCode,
                      'students',
                    ),
                  ),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.event_busy_outlined),
                  selectedIcon: const Icon(Icons.event_busy),
                  label: Text(
                    AppStrings.get(
                      context.read<AppState>().locale.languageCode,
                      'absences',
                    ),
                  ),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(
                    AppStrings.get(
                      context.read<AppState>().locale.languageCode,
                      'settings',
                    ),
                  ),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () => context.read<AppState>().logout(),
                      tooltip: 'Logout',
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(selectedIndex),
                  Expanded(
                    child: IndexedStack(
                      index: selectedIndex,
                      children: const [
                        DashboardScreen(),
                        ScheduleScreen(),
                        TeachersScreen(),
                        StudentsScreen(),
                        AbsencesScreen(),
                        SettingsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(int selectedIndex) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Text(
            _getScreenTitle(selectedIndex),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: Consumer<AppState>(
              builder: (context, appState, _) {
                return Badge(
                  isLabelVisible: appState.notifications.isNotEmpty,
                  label: Text('${appState.notifications.length}'),
                  child: const Icon(Icons.notifications_none),
                );
              },
            ),
            itemBuilder: (context) {
              final appState = context.read<AppState>();
              final lang = appState.locale.languageCode;
              final notifications = appState.notifications;

              if (notifications.isEmpty) {
                return [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('No new notifications'),
                  ),
                ];
              }

              return [
                ...notifications.map((n) {
                  final title = n.titleKey != null
                      ? AppStrings.get(lang, n.titleKey!, n.args)
                      : n.title;
                  final message = n.messageKey != null
                      ? AppStrings.get(lang, n.messageKey!, n.args)
                      : n.message;

                  return PopupMenuItem(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(message, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }),
                const PopupMenuDivider(),
                PopupMenuItem(
                  onTap: () {
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () => appState.clearNotifications(),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 16),
          const SizedBox(width: 8),
          Consumer<AppState>(
            builder: (context, appState, _) {
              final lang = appState.locale.languageCode;
              final initial = appState.currentUserName.isNotEmpty
                  ? appState.currentUserName[0].toUpperCase()
                  : '?';

              return PopupMenuButton<String>(
                offset: const Offset(0, 50),
                child: CircleAvatar(
                  backgroundColor: Colors.purple.shade100,
                  foregroundColor: Colors.purple.shade900,
                  child: Text(
                    initial,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'settings') {
                    context.read<AppState>().setTabIndex(5);
                  } else if (value == 'profile') {
                    _showEditProfileDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(AppStrings.get(lang, 'edit_profile')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(AppStrings.get(lang, 'settings')),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Schedule';
      case 2:
        return 'Teachers';
      case 3:
        return 'Students';
      case 4:
        return 'Absences';
      default:
        return 'Guardiapp';
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final appState = context.read<AppState>();
    final lang = appState.locale.languageCode;
    final nameController = TextEditingController(
      text: appState.currentUserName,
    );
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get(lang, 'edit_profile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (appState.currentUserRole != 'admin')
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get(lang, 'name'),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'new_password'),
                prefixIcon: const Icon(Icons.lock),
                helperText: 'Leave empty to keep current',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get(lang, 'cancel')),
          ),
          FilledButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newPass = passwordController.text.trim();

              if (newName.isNotEmpty) {
                Provider.of<AppState>(context, listen: false).updateProfile(
                  name: appState.currentUserRole != 'admin' ? newName : null,
                  password: newPass.isNotEmpty ? newPass : null,
                );
                Navigator.pop(context);
              }
            },
            child: Text(AppStrings.get(lang, 'save_changes')),
          ),
        ],
      ),
    );
  }
}
