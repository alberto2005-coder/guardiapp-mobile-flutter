import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';
import 'package:flutter_widgets_guardiapp/models/models.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';

class AbsencesScreen extends StatelessWidget {
  const AbsencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(child: _buildAbsenceList(context)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final lang = context.watch<AppState>().locale.languageCode;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.get(lang, 'absence_requests'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          FilledButton.icon(
            onPressed: () => _showRequestDialog(context),
            icon: const Icon(Icons.add),
            label: Text(AppStrings.get(lang, 'new_request')),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenceList(BuildContext context) {
    final appState = context.watch<AppState>();
    final absences = appState.absences;
    final lang = appState.locale.languageCode;

    if (absences.isEmpty) {
      return Center(
        child: Text(
          AppStrings.get(lang, 'no_absence_requests_found') !=
                  'no_absence_requests_found'
              ? AppStrings.get(lang, 'no_absence_requests_found')
              : 'No absence requests found',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: absences.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildRequestItem(context, absences[index]);
      },
    );
  }

  Widget _buildRequestItem(BuildContext context, Absence absence) {
    final statusColor = absence.status == AbsenceStatus.approved
        ? Colors.green
        : (absence.status == AbsenceStatus.rejected
              ? Colors.red
              : Colors.orange);

    final statusIcon = absence.status == AbsenceStatus.approved
        ? Icons.check_circle
        : (absence.status == AbsenceStatus.rejected
              ? Icons.cancel
              : Icons.hourglass_empty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.1),
            child: Text(
              absence.teacherName.isNotEmpty
                  ? absence.teacherName.substring(0, 1)
                  : '?',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  absence.teacherName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  absence.type.name.toUpperCase(),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${DateFormat('MM/dd').format(absence.startDate)} - ${DateFormat('MM/dd').format(absence.endDate)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          if (absence.status == AbsenceStatus.pending) ...[
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () {
                context.read<AppState>().updateAbsenceStatus(
                  absence.id,
                  AbsenceStatus.approved,
                );
              },
              tooltip: 'Approve',
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () {
                context.read<AppState>().updateAbsenceStatus(
                  absence.id,
                  AbsenceStatus.rejected,
                );
              },
              tooltip: 'Reject',
            ),
          ] else ...[
            Icon(statusIcon, color: statusColor),
            if (context.read<AppState>().currentUserRole == 'admin') ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => _showDeleteAbsenceDialog(context, absence),
                tooltip: 'Delete',
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showDeleteAbsenceDialog(BuildContext context, Absence absence) {
    final lang = context.read<AppState>().locale.languageCode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get(lang, 'delete_absence')),
        content: Text(AppStrings.get(lang, 'delete_absence_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get(lang, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteAbsence(absence.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppStrings.get(lang, 'delete')),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog(BuildContext context) {
    final appState = context.read<AppState>();
    final teachers = appState.teachers;
    final lang = appState.locale.languageCode;

    if (teachers.isEmpty) return;

    String selectedTeacherId = teachers.first.id;
    AbsenceType selectedType = AbsenceType.sick;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppStrings.get(lang, 'request_absence')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedTeacherId,
                items: teachers
                    .map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedTeacherId = v!),
                decoration: const InputDecoration(labelText: 'Teacher'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AbsenceType>(
                value: selectedType,
                items: AbsenceType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 16),
              const Text('Duration: 2 days (Fixed for Demo)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.get(lang, 'cancel')),
            ),
            FilledButton(
              onPressed: () {
                context.read<AppState>().requestAbsence(
                  selectedTeacherId,
                  DateTime.now(),
                  DateTime.now().add(const Duration(days: 2)),
                  selectedType,
                );
                Navigator.pop(context);
              },
              child: Text(AppStrings.get(lang, 'submit')),
            ),
          ],
        ),
      ),
    );
  }
}
