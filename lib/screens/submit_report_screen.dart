import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'my_reports_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SubmitReportScreen extends StatefulWidget {
  static const routeName = '/submit-report';
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  XFile? _selectedImage;

  double latitude = 0;
  double longitude = 0;

  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  String _category = 'Lighting';
  bool _photoAttached = false;
  bool _locationCaptured = false;
  String _locationText = 'No location captured yet';

  void _mockCamera() {
    setState(() => _photoAttached = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Photo attached. Camera package will be connected later.')),
    );
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latitude = position.latitude;
    longitude = position.longitude;

    print(latitude);
    print(longitude);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      _locationCaptured = true;

      _locationText =
          "${place.street}, ${place.locality}, ${place.administrativeArea}";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Real GPS location captured successfully'),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_photoAttached || !_locationCaptured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please attach a photo and capture GPS location before submitting.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('reports').add({
      'title': titleController.text,
      'reportedByRole': 'Resident',
      'reportedByEmail': FirebaseAuth.instance.currentUser?.email ?? '',
      'description': descController.text,
      'category': _category,
      'status': 'Pending Approval',
      'approvedBy': '',
      'assignedToSecurity': false,
      'location': _locationText,
      'address': _locationText,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': _selectedImage?.path ?? '',
      'createdAt': Timestamp.now(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Submitted'),
        content: const Text(
            'Your hazard report has been saved in the frontend prototype. Firebase will be connected in the backend stage.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, MyReportsScreen.routeName);
            },
            child: const Text('View Reports'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      title: 'Submit Report',
      selectedIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              PrimaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hazard Details',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                          labelText: 'Report Title',
                          prefixIcon: Icon(Icons.title)),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter report title'
                              : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined)),
                      items: const [
                        DropdownMenuItem(
                            value: 'Lighting', child: Text('Lighting')),
                        DropdownMenuItem(
                            value: 'Footpath', child: Text('Footpath')),
                        DropdownMenuItem(
                            value: 'Flooding', child: Text('Flooding')),
                        DropdownMenuItem(
                            value: 'Graffiti', child: Text('Graffiti')),
                        DropdownMenuItem(
                            value: 'Unsafe Area', child: Text('Unsafe Area')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) =>
                          setState(() => _category = value ?? 'Lighting'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      maxLines: 4,
                      controller: descController,
                      decoration: const InputDecoration(
                          labelText: 'Description', alignLabelWithHint: true),
                      validator: (value) =>
                          value == null || value.trim().length < 10
                              ? 'Enter at least 10 characters'
                              : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PrimaryCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                          _photoAttached
                              ? Icons.check_circle
                              : Icons.camera_alt_outlined,
                          color: _photoAttached
                              ? AppTheme.secondary
                              : AppTheme.primary),
                      title: const Text('Photo Evidence'),
                      subtitle: Text(_photoAttached
                          ? 'Photo attached successfully'
                          : 'Take or attach a hazard photo'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.camera,
                          );

                          if (image != null) {
                            setState(() {
                              _selectedImage = image;
                              _photoAttached = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(96, 44)),
                        child: const Text('Camera'),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                          _locationCaptured
                              ? Icons.check_circle
                              : Icons.my_location,
                          color: _locationCaptured
                              ? AppTheme.secondary
                              : AppTheme.primary),
                      title: const Text('GPS Location'),
                      subtitle: Text(_locationText),
                      trailing: ElevatedButton(
                        onPressed: _getCurrentLocation,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(96, 44)),
                        child: const Text('GPS'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Submit Report'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
