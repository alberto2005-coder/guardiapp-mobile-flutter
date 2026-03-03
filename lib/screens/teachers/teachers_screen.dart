import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';
import 'package:flutter_widgets_guardiapp/models/models.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';
import 'package:flutter_widgets_guardiapp/screens/schedule/schedule_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_widgets_guardiapp/widgets/skeleton_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widgets_guardiapp/screens/teachers/teacher_edit_screen.dart';

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

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
              final teachers = appState.teachers;
              final lang = appState.locale.languageCode;
              if (teachers.isEmpty) {
                return Center(
                  child: Text(AppStrings.get(lang, 'no_teachers_found')),
                );
              }
              return AnimationLimiter(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: teachers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildTeacherCard(
                            context,
                            teachers[index],
                            lang,
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
    final appState = context.watch<AppState>();
    final lang = appState.locale.languageCode;
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
              hintText: AppStrings.get(lang, 'search_teachers'),
              leading: const Icon(Icons.search, color: Colors.grey),
              padding: const MaterialStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
              elevation: const MaterialStatePropertyAll(0),
              backgroundColor: MaterialStatePropertyAll(Colors.grey.shade100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(BuildContext context, Teacher teacher, String lang) {
    final appState = context.read<AppState>();
    final isAdmin = appState.currentUserRole == 'admin';

    final cardContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'teacher-${teacher.id}',
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: teacher.avatarColor,
                  child: Text(
                    teacher.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: teacher.isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  teacher.role,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScheduleScreen(teacherId: teacher.id),
                ),
              );
            },
            tooltip: AppStrings.get(lang, 'schedule'),
            color: Colors.blue.shade400,
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherEditScreen(teacher: teacher),
                  ),
                );
              },
              tooltip: 'Edit Teacher',
              color: Colors.orange.shade400,
            ),
        ],
      ),
    );

    if (!isAdmin) {
      return cardContent;
    }

    return Slidable(
      key: ValueKey(teacher.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherEditScreen(teacher: teacher),
                ),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
              _confirmDelete(context, teacher);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: cardContent,
    );
  }

  void _confirmDelete(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AppState>().deleteTeacher(teacher.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
