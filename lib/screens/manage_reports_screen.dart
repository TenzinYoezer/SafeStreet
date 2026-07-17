import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_details_screen.dart';

class ManageReportsScreen extends StatefulWidget {
  const ManageReportsScreen({super.key});

  @override
  State<ManageReportsScreen> createState() => _ManageReportsScreenState();
}

class _ManageReportsScreenState extends State<ManageReportsScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: const Text(
          "Council Dashboard",
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy(
              'createdAt',
              descending: true,
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
                "No reports available",
              ),
            );
          }

          final reports = snapshot.data!.docs;

          // FILTERING

          final filteredReports = selectedFilter == 'All'
              ? reports
              : reports.where((report) {
                  return report['status'] == selectedFilter;
                }).toList();

          return Column(
            children: [
              // FILTER DROPDOWN

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedFilter,
                  decoration: InputDecoration(
                    labelText: 'Filter Reports',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text(
                        'All Reports',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Pending Approval',
                      child: Text(
                        'Pending Approval',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Approved',
                      child: Text(
                        'Approved',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Rejected',
                      child: Text(
                        'Rejected',
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
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),

              // REPORTS

              Expanded(
                child: ListView.builder(
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];

                    final currentStatus = report['status'];

                    // STATUS COLORS

                    Color statusColor = Colors.orange;

                    if (currentStatus == 'Approved') {
                      statusColor = Colors.green;
                    } else if (currentStatus == 'Rejected') {
                      statusColor = Colors.red;
                    } else if (currentStatus == 'In Progress') {
                      statusColor = Colors.blue;
                    } else if (currentStatus == 'Completed') {
                      statusColor = Colors.teal;
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(
                        18,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ReportDetailsScreen.routeName,
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

                              const SizedBox(height: 18),

                              // STATUS BADGE

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  currentStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                                    value: 'Pending Approval',
                                    child: Text(
                                      'Pending Approval',
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Approved',
                                    child: Text(
                                      'Approved',
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Rejected',
                                    child: Text(
                                      'Rejected',
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
                                  bool sendToSecurity = false;

                                  // SECURITY SHOULD SEE THESE

                                  if (value == 'Approved' ||
                                      value == 'In Progress' ||
                                      value == 'Completed') {
                                    sendToSecurity = true;
                                  }

                                  await FirebaseFirestore.instance
                                      .collection('reports')
                                      .doc(report.id)
                                      .update({
                                    'status': value,
                                    'assignedToSecurity': sendToSecurity,
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Status updated to $value',
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
