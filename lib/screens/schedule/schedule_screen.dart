import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';
import 'package:flutter_widgets_guardiapp/models/models.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';

class ScheduleScreen extends StatefulWidget {
  final String? teacherId;

  const ScheduleScreen({super.key, this.teacherId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _selectedDepartment;
  String? _filterTeacherId;

  @override
  void initState() {
    super.initState();
    _filterTeacherId = widget.teacherId;
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _buildHeader(context),
        Expanded(child: _buildWeeklyGrid(context)),
      ],
    );

    if (widget.teacherId != null) {
      return Scaffold(body: SafeArea(child: content));
    }

    return content;
  }

  Widget _buildHeader(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.locale.languageCode;

    final startOfWeek = appState.focusedDate.subtract(
      Duration(days: appState.focusedDate.weekday - 1),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    String? title;
    if (widget.teacherId != null) {
      final teacher = appState.teachers.firstWhere(
        (t) => t.id == widget.teacherId,
        orElse: () => Teacher(
          id: '',
          name: '',
          role: '',
          initials: '',
          avatarColor: Colors.grey,
        ),
      );
      if (teacher.id.isNotEmpty) {
        title = AppStrings.get(lang, 'teacher_schedule', {
          'name': teacher.name,
        });
      }
    }

    String dateRange;
    if (startOfWeek.year != endOfWeek.year) {
      dateRange =
          '${DateFormat('d MMM y', lang).format(startOfWeek)} - ${DateFormat('d MMM y', lang).format(endOfWeek)}';
    } else {
      dateRange =
          '${DateFormat('d MMM', lang).format(startOfWeek)} - ${DateFormat('d MMM y', lang).format(endOfWeek)}';
    }

    final departments = appState.departments;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // Filter Row
          if (widget.teacherId == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: InputDecoration(
                        labelText: AppStrings.get(lang, 'filter_by_department'),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(AppStrings.get(lang, 'all_departments')),
                        ),
                        ...departments.map(
                          (d) => DropdownMenuItem(value: d, child: Text(d)),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedDepartment = v),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  appState.updateFocusedDate(
                    appState.focusedDate.subtract(const Duration(days: 7)),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dateRange,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  appState.updateFocusedDate(
                    appState.focusedDate.add(const Duration(days: 7)),
                  );
                },
              ),
              const Spacer(),
              Flexible(
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(
                        AppStrings.get(lang, '5_days'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(
                        AppStrings.get(lang, '7_days'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  selected: {appState.is7DayView},
                  onSelectionChanged: (Set<bool> newSelection) {
                    context.read<AppState>().toggleView();
                  },
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGrid(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.locale.languageCode;
    final daysToShow = appState.is7DayView ? 7 : 5;

    final startOfWeek = appState.focusedDate.subtract(
      Duration(days: appState.focusedDate.weekday - 1),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(daysToShow, (index) {
              final currentDate = startOfWeek.add(Duration(days: index));
              final dayName = DateFormat('E', lang).format(currentDate);
              final capitalizedDayName =
                  dayName.substring(0, 1).toUpperCase() + dayName.substring(1);

              final now = DateTime.now();
              final isToday =
                  now.day == currentDate.day &&
                  now.month == currentDate.month &&
                  now.year == currentDate.year;

              final dayShifts = appState.shifts.where((s) {
                final matchesDate =
                    s.date.day == currentDate.day &&
                    s.date.month == currentDate.month &&
                    s.date.year == currentDate.year;

                if (!matchesDate) return false;

                if (_filterTeacherId != null) {
                  return s.teacherId == _filterTeacherId;
                }

                if (_selectedDepartment != null) {
                  final teacher = appState.teachers.firstWhere(
                    (t) => t.id == s.teacherId,
                    orElse: () => Teacher(
                      id: '',
                      name: '',
                      role: '',
                      initials: '',
                      avatarColor: Colors.grey,
                    ),
                  );
                  return teacher.department == _selectedDepartment;
                }

                return true;
              }).toList();

              return InkWell(
                onLongPress: () => _showAddShiftDialog(context, currentDate),
                child: Container(
                  width: 200,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: isToday
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.transparent,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              capitalizedDayName,
                              style: TextStyle(
                                color: isToday
                                    ? Colors.blue.shade800
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d MMM', lang).format(currentDate),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isToday
                                    ? Colors.blue.shade800
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),
                      Expanded(
                        child: appState.isHoliday(currentDate)
                            ? _buildHolidayView(appState, currentDate)
                            : _buildShiftsList(
                                context,
                                dayShifts,
                                currentDate,
                                lang,
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildHolidayView(AppState appState, DateTime date) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 32),
            const SizedBox(height: 8),
            Text(
              appState.getHolidayName(date) ?? 'Holiday',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftsList(
    BuildContext context,
    List<Shift> shifts,
    DateTime date,
    String lang,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (shifts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                AppStrings.get(lang, 'no_shifts'),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ...shifts.map(
            (shift) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  if (context.read<AppState>().canEditShift(shift)) {
                    _showDeleteShiftDialog(context, shift);
                  }
                },
                child: _buildShiftCard(shift),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap:
                  (widget.teacherId != null &&
                      !context.read<AppState>().isAdmin &&
                      widget.teacherId !=
                          context.read<AppState>().currentUserId)
                  ? null
                  : () => _showAddShiftDialog(context, date),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.add_circle_outline,
                  color:
                      (widget.teacherId != null &&
                          !context.read<AppState>().isAdmin &&
                          widget.teacherId !=
                              context.read<AppState>().currentUserId)
                      ? Colors.transparent
                      : Colors.grey.shade400,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(Shift shift) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: shift.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: shift.color.withOpacity(1.0), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(
                '${shift.startTime} - ${shift.endTime}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            shift.subject,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            shift.teacherName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddShiftDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) =>
          _AddShiftDialog(date: date, preselectedTeacherId: widget.teacherId),
    );
  }

  void _showDeleteShiftDialog(BuildContext context, Shift shift) {
    final lang = context.read<AppState>().locale.languageCode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get(lang, 'delete_shift')),
        content: Text(AppStrings.get(lang, 'delete_shift_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get(lang, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteShift(shift.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppStrings.get(lang, 'delete')),
          ),
        ],
      ),
    );
  }
}

class _AddShiftDialog extends StatefulWidget {
  final DateTime date;
  final String? preselectedTeacherId;
  const _AddShiftDialog({required this.date, this.preselectedTeacherId});

  @override
  State<_AddShiftDialog> createState() => _AddShiftDialogState();
}

class _AddShiftDialogState extends State<_AddShiftDialog> {
  late String _selectedTeacherId;
  final _subjectController = TextEditingController();
  final _startController = TextEditingController(text: '09:00');
  final _endController = TextEditingController(text: '10:30');

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();

    if (widget.preselectedTeacherId != null) {
      _selectedTeacherId = widget.preselectedTeacherId!;
    } else if (!appState.isAdmin) {
      _selectedTeacherId = appState.currentUserId;
    } else {
      final teachers = appState.teachers;
      if (teachers.isNotEmpty) {
        _selectedTeacherId = teachers.first.id;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final teachers = appState.teachers;
    final lang = appState.locale.languageCode;

    if (teachers.isEmpty) {
      return AlertDialog(
        content: Text(AppStrings.get(lang, 'no_teachers_found')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get(lang, 'cancel')),
          ),
        ],
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        '${AppStrings.get(lang, 'add_shift')} - ${DateFormat('d MMM', lang).format(widget.date)}',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (appState.isAdmin)
              DropdownButtonFormField<String>(
                value: _selectedTeacherId,
                items: teachers
                    .map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedTeacherId = v!),
                decoration: InputDecoration(
                  labelText: AppStrings.get(lang, 'teacher_label'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'subject'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startController,
                    decoration: InputDecoration(
                      labelText: AppStrings.get(lang, 'start_time'),
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.schedule, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endController,
                    decoration: InputDecoration(
                      labelText: AppStrings.get(lang, 'end_time'),
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.schedule, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.get(lang, 'cancel')),
        ),
        FilledButton(
          onPressed: () {
            if (_subjectController.text.isNotEmpty) {
              context.read<AppState>().addShift(
                _selectedTeacherId,
                widget.date,
                _startController.text,
                _endController.text,
                _subjectController.text,
              );
              Navigator.pop(context);
            }
          },
          child: Text(AppStrings.get(lang, 'add_shift')),
        ),
      ],
    );
  }
}
