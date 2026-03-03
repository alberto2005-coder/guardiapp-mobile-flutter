import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';
import 'package:flutter_widgets_guardiapp/utils/app_strings.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onTapDetails;
  final VoidCallback? onTapRefresh;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
    this.onTapDetails,
    this.onTapRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().locale.languageCode;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Colors.grey.shade400,
                        ),
                        onSelected: (value) {
                          if (value == 'details' && onTapDetails != null) {
                            onTapDetails!();
                          }
                          if (value == 'refresh' && onTapRefresh != null) {
                            onTapRefresh!();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'details',
                            child: Text(AppStrings.get(lang, 'view_details')),
                          ),
                          PopupMenuItem(
                            value: 'refresh',
                            child: Text(AppStrings.get(lang, 'refresh_data')),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
