import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';
import 'package:day_night_switcher/day_night_switcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(
            context,
            AppStrings.get(appState.locale.languageCode, 'preferences'),
          ),
          ListTile(
            title: Text(
              AppStrings.get(appState.locale.languageCode, 'dark_mode'),
            ),
            trailing: SizedBox(
              width: 60,
              height: 40,
              child: DayNightSwitcher(
                isDarkModeEnabled: appState.themeMode == ThemeMode.dark,
                onStateChanged: (_) => appState.toggleTheme(),
              ),
            ),
          ),
          ListTile(
            title: Text(
              AppStrings.get(appState.locale.languageCode, 'language'),
            ),
            subtitle: Text(
              appState.locale.languageCode == 'en' ? 'English' : 'Español',
            ),
            trailing: const Icon(Icons.language),
            onTap: () => appState.switchLanguage(),
          ),
          const Divider(height: 32),
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            title: const Text('Custom Background'),
            subtitle: Text(
              appState.currentBackgroundPath != null
                  ? 'Custom Image Selected'
                  : 'Default',
            ),
            trailing: const Icon(Icons.wallpaper),
            onTap: () => _showBackgroundSelectionDialog(context),
          ),
          const Divider(height: 32),
          _buildSectionHeader(
            context,
            AppStrings.get(appState.locale.languageCode, 'account'),
          ),
          ListTile(
            title: Text(
              AppStrings.get(appState.locale.languageCode, 'change_password'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context),
          ),
          if (appState.currentUserRole == 'admin') ...[
            ListTile(
              title: Text(
                AppStrings.get(
                  appState.locale.languageCode,
                  'admin_privileges',
                ),
              ),
              subtitle: Text(
                AppStrings.get(appState.locale.languageCode, 'full_access'),
              ),
              leading: const Icon(Icons.security, color: Colors.blue),
            ),
            ListTile(
              title: const Text('Manage Departments'),
              leading: const Icon(Icons.business),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showManageDepartmentsDialog(context),
            ),
          ] else ...[
            // For Teachers
            ListTile(
              title: Text(
                AppStrings.get(appState.locale.languageCode, 'department'),
              ),
              subtitle: Text(_getCurrentDepartment(context) ?? 'None'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showSelectDepartmentDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Old Password'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              try {
                context.read<AppState>().updateProfile(
                  password: newPassController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String? _getCurrentDepartment(BuildContext context) {
    final appState = context.read<AppState>();
    try {
      final teacher = appState.teachers.firstWhere(
        (t) => t.id == appState.currentUserId,
      );
      return teacher.department;
    } catch (_) {
      return null;
    }
  }

  void _showSelectDepartmentDialog(BuildContext context) {
    final appState = context.read<AppState>();
    String? selected = _getCurrentDepartment(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              AppStrings.get(appState.locale.languageCode, 'select_department'),
            ),
            content: DropdownButtonFormField<String>(
              value: selected,
              isExpanded: true,
              items: appState.departments
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => selected = v),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.get(appState.locale.languageCode, 'cancel'),
                ),
              ),
              FilledButton(
                onPressed: () {
                  if (selected != null) {
                    appState.updateProfile(department: selected);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  AppStrings.get(appState.locale.languageCode, 'save_changes'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManageDepartmentsDialog(BuildContext context) {
    final appState = context.read<AppState>();
    final newDeptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Manage Departments'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newDeptController,
                          decoration: const InputDecoration(
                            labelText: 'New Department Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          if (newDeptController.text.isNotEmpty) {
                            appState.addDepartment(newDeptController.text);
                            newDeptController.clear();
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: appState.departments.length,
                      itemBuilder: (context, index) {
                        final dept = appState.departments[index];
                        return ListTile(
                          title: Text(dept),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              if (appState.departments.length <= 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Cannot delete the last department',
                                    ),
                                  ),
                                );
                                return;
                              }
                              appState.removeDepartment(dept);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBackgroundSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _BackgroundSelectionDialog(),
    );
  }
}

class _BackgroundSelectionDialog extends StatefulWidget {
  const _BackgroundSelectionDialog();

  @override
  State<_BackgroundSelectionDialog> createState() =>
      _BackgroundSelectionDialogState();
}

class _BackgroundSelectionDialogState
    extends State<_BackgroundSelectionDialog> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return AlertDialog(
          title: const Text('Select Background'),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('None (Default)'),
                  onTap: () {
                    appState.setBackground(null);
                    Navigator.pop(context);
                  },
                  selected: appState.currentBackgroundPath == null,
                ),
                const Divider(),
                Flexible(
                  child: appState.availableBackgrounds.isEmpty
                      ? const Center(
                          child: Text(
                            'No custom backgrounds found.\nImport one to get started!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: GridView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(
                              left: 4,
                              top: 4,
                              bottom: 4,
                              right: 12, // Added padding for scrollbar space
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: appState.availableBackgrounds.length,
                            itemBuilder: (context, index) {
                              final path = appState.availableBackgrounds[index];
                              final isSelected =
                                  appState.currentBackgroundPath == path;
                              final isAsset = path.startsWith('assets/');

                              return GestureDetector(
                                onTap: () {
                                  appState.setBackground(path);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    border: isSelected
                                        ? Border.all(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            width: 4,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: isAsset
                                        ? Image.asset(
                                            path,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, _, __) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                    size: 32,
                                                  ),
                                                ),
                                          )
                                        : Image.file(
                                            File(path),
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, _, __) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                    size: 32,
                                                  ),
                                                ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                try {
                  await appState.importBackground();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error importing file: $e')),
                  );
                }
              },
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Import Image/GIF'),
            ),
          ],
        );
      },
    );
  }
}
