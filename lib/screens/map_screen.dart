import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  final LatLng initialPosition = const LatLng(
    -35.2809,
    149.1300,
  );

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    loadMarkers();
  }

  Future<void> loadMarkers() async {
    final reports =
        await FirebaseFirestore.instance.collection('reports').get();

    Set<Marker> loadedMarkers = {};

    for (var report in reports.docs) {
      final data = report.data();

      if (data['latitude'] != null && data['longitude'] != null) {
        loadedMarkers.add(
          Marker(
            markerId: MarkerId(report.id),
            position: LatLng(
              data['latitude'],
              data['longitude'],
            ),
            infoWindow: InfoWindow(
              title: data['title'] ?? '',
              snippet: data['status'] ?? '',
            ),
          ),
        );
      }
    }

    setState(() {
      markers = loadedMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Incident Map",
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 12,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}
