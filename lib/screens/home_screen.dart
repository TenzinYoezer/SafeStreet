import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'submit_report_screen.dart';
import 'my_reports_screen.dart';
import 'report_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  Widget _buildStatusCard(
    IconData icon,
    String count,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
            size: 28,
          ),
          const SizedBox(height: 14),
          Text(
            count,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('reports').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final reportsSnapshot = snapshot.data!.docs;

        final pending =
            reportsSnapshot.where((d) => d['status'] == 'Pending').length;

        final progress = reportsSnapshot
            .where((d) => d['status'] == 'Under Investigation')
            .length;

        final resolved =
            reportsSnapshot.where((d) => d['status'] == 'Resolved').length;

        return BottomNavScaffold(
          title: 'SafeStreet Dashboard',
          selectedIndex: 0,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // WELCOME CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: userDoc.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text(
                              'Welcome, User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }

                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;

                          return Text(
                            'Welcome, ${data['name']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Report community hazards with photos and GPS location.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // STATUS CARDS
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        Icons.pending_actions,
                        pending.toString(),
                        'Pending',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatusCard(
                        Icons.build,
                        progress.toString(),
                        'Investigating',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatusCard(
                        Icons.verified,
                        resolved.toString(),
                        'Resolved',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        SubmitReportScreen.routeName,
                      );
                    },
                    child: const Text(
                      'Submit New Hazard Report',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // VIEW REPORTS BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        MyReportsScreen.routeName,
                      );
                    },
                    child: const Text(
                      'View My Reports',
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // RECENT REPORTS
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reportsSnapshot.length,
                  itemBuilder: (context, index) {
                    final report = reportsSnapshot[index];

                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ReportDetailsScreen.routeName,
                          arguments: report.data() as Map<String, dynamic>,
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: ListTile(
                          leading: const Icon(
                            Icons.warning,
                            color: AppTheme.primary,
                          ),
                          title: Text(
                            report['title'] ?? 'No Title',
                          ),
                          subtitle: Text(
                            report['status'] ?? 'Pending',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
