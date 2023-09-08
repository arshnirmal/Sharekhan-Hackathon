import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LocationData? _currentLocation;
  Timer? _timer;

  getCurrentLocation() async {
    Location location = Location();
    await location.getLocation().then(
      (value) {
        _currentLocation = value;
        print('Current Location: $_currentLocation');
      },
    );

    setState(() {
      _currentLocation = _currentLocation;
    });
  }

  Future<void> sendLocationToFirestore() async {
    final CollectionReference beaconsCollection = FirebaseFirestore.instance.collection('beacons');
    final DocumentReference userDoc = beaconsCollection.doc(FirebaseAuth.instance.currentUser!.uid);
    Location location = Location();
    LocationData position = await location.getLocation();

    final Map<String, dynamic> locationData = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now(),
    };

    print('Sending location to Firestore: $locationData');

    await userDoc.update(locationData);
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (Timer timer) async {
        print('Timer triggered');
        await sendLocationToFirestore();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentLocation?.latitude}, ${_currentLocation?.longitude}'),
        actions: [
          IconButton(
            onPressed: () async {
              await sendLocationToFirestore();
            },
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: _currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentLocation?.latitude ?? 0,
                  _currentLocation?.longitude ?? 0,
                ),
                zoom: 14.4746,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              indoorViewEnabled: true,
              mapToolbarEnabled: true,
            ),
    );
  }
}
