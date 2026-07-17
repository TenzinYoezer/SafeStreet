import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return BottomNavScaffold(
      title: 'Profile',
      selectedIndex: 3,
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // PROFILE CARD
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'User';

              final email = data['email'] ?? 'No Email';

              final role = data['role'] ?? 'Resident';

              return PrimaryCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Chip(
                      backgroundColor: AppTheme.secondary.withOpacity(0.12),
                      label: Text(
                        '$role Account',
                        style: const TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // MENU CARD
          PrimaryCard(
            child: Column(
              children: [
                // EDIT PROFILE
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                  ),
                  title: const Text(
                    'Edit Profile',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      EditProfileScreen.routeName,
                    );
                  },
                ),

                // NOTIFICATIONS
                ListTile(
                  leading: const Icon(
                    Icons.notifications_outlined,
                  ),
                  title: const Text(
                    'Notification Preferences',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Notification settings coming soon',
                        ),
                      ),
                    );
                  },
                ),

                // SETTINGS
                ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                  ),
                  title: const Text(
                    'Settings',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      SettingsScreen.routeName,
                    );
                  },
                ),

                // HELP GUIDE
                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                  ),
                  title: const Text(
                    'Help & Safety Guide',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            'Help & Safety Guide',
                          ),
                          content: const Text(
                            '• Report hazards responsibly\n\n'
                            '• Avoid dangerous areas\n\n'
                            '• Emergency: Call 000\n\n'
                            '• Keep location services enabled',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Close',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                // LOGOUT
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                  ),
                  title: const Text(
                    'Logout',
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginScreen.routeName,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
