import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ReportDetailsScreen extends StatelessWidget {
  static const routeName = '/report-details';

  const ReportDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // IMAGE
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(22),
            ),
            child: report['imagePath'] != null &&
                    report['imagePath'].toString().isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImage(
                            imagePath: report['imagePath'],
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.file(
                        File(
                          report['imagePath'],
                        ),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: AppTheme.primary,
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // MAIN DETAILS CARD
          PrimaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE + STATUS
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report['title'] ?? 'Untitled Report',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    StatusChip(
                      status: report['status'] ?? 'Pending',
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  'Report ID: ${report['id'] ?? 'N/A'}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                  ),
                ),

                const Divider(height: 28),

                // CATEGORY
                _DetailRow(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: report['category'] ?? 'Not provided',
                ),

                // DESCRIPTION
                _DetailRow(
                  icon: Icons.description_outlined,
                  label: 'Description',
                  value: report['description'] ?? 'No description',
                ),

                // LOCATION
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: report['location'] ?? 'No location',
                ),

                // COORDINATES
                _DetailRow(
                  icon: Icons.map_outlined,
                  label: 'Coordinates',
                  value: '${report['latitude'] ?? 'N/A'}, '
                      '${report['longitude'] ?? 'N/A'}',
                ),

                // IMAGE PATH
                _DetailRow(
                  icon: Icons.camera_alt_outlined,
                  label: 'Image',
                  value: report['imagePath'] ?? 'No image uploaded',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // TIMELINE CARD
          PrimaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _TimelineItem(
                  done: true,
                  title: 'Report submitted',
                  subtitle: 'Resident submitted the hazard report.',
                ),
                _TimelineItem(
                  done: report['status'] != 'Pending',
                  title: 'Council reviewing',
                  subtitle: 'Maintenance team is checking the issue.',
                ),
                _TimelineItem(
                  done: report['status'] == 'Resolved' ||
                      report['status'] == 'Closed',
                  title: 'Resolved',
                  subtitle: 'Hazard has been fixed or closed.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // LOCATION BUTTON
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/mapScreen',
              );
            },
            icon: const Icon(
              Icons.share_location_outlined,
            ),
            label: const Text(
              'Open Location on Map',
            ),
          ),
        ],
      ),
    );
  }
}

// DETAIL ROW
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TIMELINE ITEM
class _TimelineItem extends StatelessWidget {
  final bool done;
  final String title;
  final String subtitle;

  const _TimelineItem({
    required this.done,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? AppTheme.secondary : AppTheme.textMuted,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(subtitle),
    );
  }
}

// FULLSCREEN IMAGE VIEWER
class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(
            File(imagePath),
          ),
        ),
      ),
    );
  }
}
