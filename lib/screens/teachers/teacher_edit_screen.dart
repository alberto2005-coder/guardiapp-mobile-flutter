import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';
import 'package:flutter_widgets_guardiapp/models/models.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';

class TeacherEditScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherEditScreen({super.key, required this.teacher});

  @override
  State<TeacherEditScreen> createState() => _TeacherEditScreenState();
}

class _TeacherEditScreenState extends State<TeacherEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _passwordController;
  String? _selectedDepartment;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher.name);
    _roleController = TextEditingController(text: widget.teacher.role);
    _passwordController = TextEditingController(text: widget.teacher.password);
    _selectedDepartment = widget.teacher.department;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.get(lang, 'edit_profile'),
        ), // Using 'edit_profile' as generic 'Edit Teacher'
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: widget.teacher.avatarColor,
              child: Text(
                widget.teacher.initials,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'name'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'department'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.business),
              ),
              items: appState.departments
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDepartment = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: 'Role (e.g. teacher, head_of_studies)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'new_password'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _saveHeader,
                icon: const Icon(Icons.save),
                label: Text(AppStrings.get(lang, 'save_changes')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveHeader() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    final updatedTeacher = Teacher(
      id: widget.teacher.id,
      name: _nameController.text.trim(),
      role: _roleController.text.trim(),
      initials: _nameController.text
          .trim()
          .split(' ')
          .take(2)
          .map((e) => e.isNotEmpty ? e[0] : '')
          .join()
          .toUpperCase(),
      avatarColor: widget.teacher.avatarColor,
      department: _selectedDepartment ?? 'General',
      isOnline: widget.teacher.isOnline,
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text
          : widget.teacher.password,
    );

    context.read<AppState>().updateTeacher(updatedTeacher);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Teacher updated successfully')),
    );
  }
}
