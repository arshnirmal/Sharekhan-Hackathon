import 'dart:async';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String uuid = '39ED98FF-2900-441A-802F-9C398FC199D2';
  static const int majorId = 1;
  static const int minorId = 100;
  static const int transmissionPower = -59;
  static const String identifier = 'com.example.myDeviceRegion';
  static const AdvertiseMode advertiseMode = AdvertiseMode.lowPower;
  static const String layout = BeaconBroadcast.ALTBEACON_LAYOUT;
  static const int manufacturerId = 0x0118;
  static const List<int> extraData = [100];

  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  bool _isAdvertising = false;
  BeaconStatus _isTransmissionSupported = BeaconStatus.notSupportedBle;
  late StreamSubscription<bool> _isAdvertisingSubscription;

  @override
  void initState() {
    super.initState();

    handlePermissions();

    beaconBroadcast.checkTransmissionSupported().then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });

    _isAdvertisingSubscription = beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Beacon Broadcast'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Is transmission supported?', style: Theme.of(context).textTheme.headlineSmall),
                Text('$_isTransmissionSupported', style: Theme.of(context).textTheme.titleMedium),
                Container(height: 16.0),
                Text('Has beacon started?', style: Theme.of(context).textTheme.headlineSmall),
                Text('$_isAdvertising', style: Theme.of(context).textTheme.titleMedium),
                Container(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      beaconBroadcast
                          .setUUID(uuid)
                          .setMajorId(majorId)
                          .setMinorId(minorId)
                          .setTransmissionPower(transmissionPower)
                          .setAdvertiseMode(advertiseMode)
                          .setIdentifier(identifier)
                          .setLayout(layout)
                          .setManufacturerId(manufacturerId)
                          .setExtraData(extraData)
                          .start();
                    },
                    child: const Text('START'),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      beaconBroadcast.stop();
                    },
                    child: const Text('STOP'),
                  ),
                ),
                Text('Beacon Data', style: Theme.of(context).textTheme.headlineSmall),
                const Text('UUID: $uuid'),
                const Text('Major id: $majorId'),
                const Text('Minor id: $minorId'),
                const Text('Tx Power: $transmissionPower'),
                Text('Advertise Mode Value: $advertiseMode'),
                const Text('Identifier: $identifier'),
                const Text('Layout: $layout'),
                const Text('Manufacturer Id: $manufacturerId'),
                Text('Extra data: $extraData'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isAdvertisingSubscription.cancel();
    super.dispose();
  }

  handlePermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothAdvertise.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
  }
}
