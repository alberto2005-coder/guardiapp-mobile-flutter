import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';
import 'package:flutter_widgets_guardiapp/models/models.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_widgets_guardiapp/widgets/skeleton_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              if (appState.isLoading) {
                return const SkeletonList();
              }
              final students = appState.students;
              if (students.isEmpty) {
                return const Center(child: Text('No students found.'));
              }
              return AnimationLimiter(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: students.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: KeyedSubtree(
                            key: ValueKey(student.id),
                            child: _buildStudentCard(context, student),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final lang = context.watch<AppState>().locale.languageCode;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SearchBar(
              hintText: AppStrings.get(lang, 'search_students'),
              leading: const Icon(Icons.search, color: Colors.grey),
              padding: const MaterialStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
              elevation: const MaterialStatePropertyAll(0),
              backgroundColor: MaterialStatePropertyAll(Colors.grey.shade100),
            ),
          ),
          const SizedBox(width: 16),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showAddStudentDialog(context),
            icon: const Icon(Icons.add),
            label: Text(AppStrings.get(lang, 'add_student')),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Student student) {
    final lang = context.watch<AppState>().locale.languageCode;
    return Slidable(
      key: ValueKey(student.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _showEditStudentDialog(context, student),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          if (context.read<AppState>().currentUserRole == 'admin')
            SlidableAction(
              onPressed: (context) =>
                  _showDeleteStudentDialog(context, student),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'student-${student.id}',
              child: CircleAvatar(
                radius: 24,
                backgroundColor: student.avatarColor,
                child: Text(
                  student.name.isNotEmpty ? student.name.substring(0, 1) : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${student.grade} • ${student.parentEmail}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mail_outline),
              onPressed: () {},
              tooltip: AppStrings.get(lang, 'email_parent'),
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();
    final emailController = TextEditingController();
    DateTime? selectedDate;
    final lang = context.read<AppState>().locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppStrings.get(lang, 'add_student')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get(lang, 'full_name'),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gradeController,
                decoration: InputDecoration(
                  labelText: AppStrings.get(lang, 'grade'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: AppStrings.get(lang, 'parent_email'),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppStrings.get(lang, 'date_of_birth'),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    selectedDate != null
                        ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                        : AppStrings.get(lang, 'pick_date'),
                  ),
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
                if (nameController.text.isNotEmpty && selectedDate != null) {
                  Provider.of<AppState>(context, listen: false).addStudent(
                    nameController.text,
                    gradeController.text,
                    emailController.text,
                    selectedDate!,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(AppStrings.get(lang, 'add')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, Student student) {
    final nameController = TextEditingController(text: student.name);
    final gradeController = TextEditingController(text: student.grade);
    final emailController = TextEditingController(text: student.parentEmail);
    DateTime? selectedDate = student.dateOfBirth;
    final lang = context.read<AppState>().locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppStrings.get(lang, 'edit_student')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get(lang, 'full_name'),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gradeController,
                decoration: InputDecoration(
                  labelText: AppStrings.get(lang, 'grade'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: AppStrings.get(lang, 'parent_email'),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppStrings.get(lang, 'date_of_birth'),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    selectedDate != null
                        ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                        : AppStrings.get(lang, 'pick_date'),
                  ),
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
                if (nameController.text.isNotEmpty && selectedDate != null) {
                  Provider.of<AppState>(context, listen: false).updateStudent(
                    student.id,
                    nameController.text,
                    gradeController.text,
                    emailController.text,
                    selectedDate!,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(AppStrings.get(lang, 'save_changes')),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteStudentDialog(BuildContext context, Student student) {
  final lang = context.read<AppState>().locale.languageCode;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppStrings.get(lang, 'delete_student')),
      content: Text(AppStrings.get(lang, 'delete_student_confirmation')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.get(lang, 'cancel')),
        ),
        TextButton(
          onPressed: () {
            context.read<AppState>().deleteStudent(student.id);
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(AppStrings.get(lang, 'delete')),
        ),
      ],
    ),
  );
}
