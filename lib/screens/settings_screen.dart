import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool shareLocation = true;
  bool useMobileData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          PrimaryCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: notifications,
                  onChanged: (value) => setState(() => notifications = value),
                  title: const Text('Status Notifications'),
                  subtitle: const Text('Receive updates when a report status changes.'),
                ),
                SwitchListTile(
                  value: shareLocation,
                  onChanged: (value) => setState(() => shareLocation = value),
                  title: const Text('Allow GPS Location'),
                  subtitle: const Text('Use device location for hazard reports.'),
                ),
                SwitchListTile(
                  value: useMobileData,
                  onChanged: (value) => setState(() => useMobileData = value),
                  title: const Text('Upload Photos on Mobile Data'),
                  subtitle: const Text('Allow image upload when Wi-Fi is not available.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const PrimaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('App Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                SizedBox(height: 10),
                Text('Version: 1.0.0 frontend prototype', style: TextStyle(color: AppTheme.textMuted)),
                SizedBox(height: 6),
                Text('Backend planned: Firebase Auth, Cloud Firestore, Firebase Storage', style: TextStyle(color: AppTheme.textMuted)),
                SizedBox(height: 6),
                Text('Sensors planned: Camera and GPS location', style: TextStyle(color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
