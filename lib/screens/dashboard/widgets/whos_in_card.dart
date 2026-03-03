import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';

class WhosInCard extends StatelessWidget {
  const WhosInCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Who's In",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    final onlineTeachers = appState.teachers
                        .where((t) => t.isOnline)
                        .toList();

                    if (onlineTeachers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text("No active users"),
                      );
                    }

                    return Row(
                      children: onlineTeachers.map((teacher) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildAvatar(
                            teacher.initials,
                            teacher.avatarColor,
                            teacher.name,
                            teacher.isOnline,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    String initials,
    Color color,
    String name,
    bool isOnline,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
