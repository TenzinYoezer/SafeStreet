class HazardReport {
  final String id;
  final String title;
  final String category;
  final String description;
  final String status;
  final String locationText;
  final double latitude;
  final double longitude;
  final String imageLabel;
  final DateTime createdAt;

  const HazardReport({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.locationText,
    required this.latitude,
    required this.longitude,
    required this.imageLabel,
    required this.createdAt,
  });
}

class DemoData {
  static final List<HazardReport> reports = [
    HazardReport(
      id: 'RPT-1001',
      title: 'Broken Streetlight',
      category: 'Lighting',
      description: 'Streetlight is not working near the park entrance.',
      status: 'Pending',
      locationText: 'Near Central Park, Sydney',
      latitude: -33.8688,
      longitude: 151.2093,
      imageLabel: 'Camera photo attached',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HazardReport(
      id: 'RPT-1002',
      title: 'Damaged Footpath',
      category: 'Footpath',
      description: 'Cracked footpath may cause people to trip.',
      status: 'In Progress',
      locationText: 'George Street, Sydney',
      latitude: -33.8710,
      longitude: 151.2060,
      imageLabel: 'Gallery image attached',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HazardReport(
      id: 'RPT-1003',
      title: 'Flooded Drain',
      category: 'Flooding',
      description: 'Drain is blocked and water is building up after rain.',
      status: 'Resolved',
      locationText: 'Community Library Car Park',
      latitude: -33.8702,
      longitude: 151.2111,
      imageLabel: 'Camera photo attached',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
}
