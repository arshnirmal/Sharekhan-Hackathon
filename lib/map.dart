import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _source = LatLng(37.42796133580664, -122.085749655962);
  static const LatLng _destination = LatLng(37.43296265331129, -122.08832357078792);
  static const LatLng giga = LatLng(19.174948649999997, 72.99253687782473);

  LocationData? _currentLocation;

  void getCurrentLocation() async {
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

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polyPointsCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      dotenv.env["GOOGLE_MAPS_API_KEY"] ?? '',
      PointLatLng(_source.latitude, _source.longitude),
      PointLatLng(_destination.latitude, _destination.longitude),
      // PointLatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0),
      // PointLatLng(giga.latitude, giga.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polyPointsCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    Future.delayed(const Duration(seconds: 2), () {
      getPolyPoints();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Indoor Navigation"),
      ),
      body: _currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0),
                zoom: 14.4746,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("source"),
                  position: _source,
                  infoWindow: const InfoWindow(title: "Source"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
                Marker(
                  markerId: const MarkerId("current"),
                  position: LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0),
                  infoWindow: const InfoWindow(title: "Current"),
                ),
                const Marker(
                  markerId: MarkerId("giga"),
                  position: giga,
                  infoWindow: InfoWindow(title: "Giga"),
                ),
                const Marker(
                  markerId: MarkerId("destination"),
                  position: _destination,
                  infoWindow: InfoWindow(title: "Destination"),
                ),
              },
              polylines: {
                const Polyline(
                  polylineId: PolylineId("route"),
                  color: Colors.blue,
                  points: [
                    // LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0),
                    // giga,
                    _source,
                    _destination,
                  ],
                  width: 3,
                ),
              },
            ),
    );
  }
}
