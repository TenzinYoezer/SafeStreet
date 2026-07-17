import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecurityReportsScreen extends StatelessWidget {
  const SecurityReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          "Approved Reports",
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where(
              'assignedToSecurity',
              isEqualTo: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          // LOADING

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // EMPTY

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No approved reports available",
              ),
            );
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];

              final currentStatus = report['status'];

              return InkWell(
                borderRadius: BorderRadius.circular(
                  18,
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/report-details',
                    arguments: {
                      'title': report['title'],
                      'description': report['description'],
                      'category': report['category'],
                      'location': report['location'],
                      'status': report['status'],
                      'reportedByEmail': report['reportedByEmail'],
                      'imagePath': report['imagePath'],
                    },
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(
                    12,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITLE

                        Text(
                          report['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // DESCRIPTION

                        Text(
                          report['description'] ?? '',
                        ),

                        const SizedBox(height: 14),

                        // CATEGORY

                        Row(
                          children: [
                            const Icon(
                              Icons.category,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              report['category'] ?? '',
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // LOCATION

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                report['location'] ?? '',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // REPORTER

                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                report['reportedByEmail'] ?? '',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // STATUS DROPDOWN

                        DropdownButtonFormField(
                          value: currentStatus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                14,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Approved',
                              child: Text(
                                'Approved',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'In Progress',
                              child: Text(
                                'In Progress',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Text(
                                'Completed',
                              ),
                            ),
                          ],
                          onChanged: (value) async {
                            await FirebaseFirestore.instance
                                .collection('reports')
                                .doc(report.id)
                                .update({
                              'status': value,

                              // KEEP REPORT
                              // VISIBLE

                              'assignedToSecurity': true,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Incident marked as $value',
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // STATUS BADGE

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              currentStatus,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            currentStatus,
                            style: TextStyle(
                              color: _getStatusColor(
                                currentStatus,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // STATUS COLORS

  static Color _getStatusColor(
    String status,
  ) {
    switch (status) {
      case 'Approved':
        return Colors.blue;

      case 'In Progress':
        return Colors.orange;

      case 'Completed':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }
}
