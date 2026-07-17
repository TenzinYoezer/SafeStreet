import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/common_widgets.dart';
import 'report_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyReportsScreen extends StatefulWidget {
  static const routeName = '/my-reports';

  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return BottomNavScaffold(
      title: 'My Reports',
      selectedIndex: 2,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;

          final role = userData['role'] ?? 'Resident';

          // RESIDENT QUERY
          Query reportsQuery;

          if (role == 'Resident') {
            reportsQuery =
                FirebaseFirestore.instance.collection('reports').where(
                      'userId',
                      isEqualTo: currentUser.uid,
                    );
          }

          // ADMIN QUERY
          else {
            reportsQuery =
                FirebaseFirestore.instance.collection('reports').orderBy(
                      'createdAt',
                      descending: true,
                    );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: reportsQuery.snapshots(),
            builder: (context, snapshot) {
              // LOADING
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // EMPTY
              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No reports recorded',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              final reports = snapshot.data!.docs;

              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];

                  // STATUS COLOR
                  Color statusColor = Colors.orange;

                  if (report['status'] == 'Resolved') {
                    statusColor = Colors.green;
                  } else if (report['status'] == 'Closed') {
                    statusColor = Colors.grey;
                  } else if (report['status'] == 'Under Investigation') {
                    statusColor = Colors.blue;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          final data = report.data() as Map<String, dynamic>;

                          data['id'] = report.id;

                          Navigator.pushNamed(
                            context,
                            ReportDetailsScreen.routeName,
                            arguments: data,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // ICON
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(width: 14),

                              // REPORT INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // TITLE
                                    Text(
                                      report['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    // CATEGORY
                                    Text(
                                      report['category'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // STATUS
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        report['status'] ?? 'Pending',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ADMIN STATUS CONTROL
                              if (role != 'Resident')
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    await FirebaseFirestore.instance
                                        .collection('reports')
                                        .doc(report.id)
                                        .update({
                                      'status': value,
                                    });
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'Pending',
                                      child: Text('Pending'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Under Investigation',
                                      child: Text(
                                        'Under Investigation',
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Resolved',
                                      child: Text('Resolved'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Closed',
                                      child: Text('Closed'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
