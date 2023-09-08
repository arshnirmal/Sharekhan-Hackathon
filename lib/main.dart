import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const BeaconScannerApp());

class BeaconScannerApp extends StatelessWidget {
  const BeaconScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BeaconScannerScreen(),
    );
  }
}

class BeaconScannerScreen extends StatefulWidget {
  const BeaconScannerScreen({super.key});

  @override
  _BeaconScannerScreenState createState() => _BeaconScannerScreenState();
}

class _BeaconScannerScreenState extends State<BeaconScannerScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  handlePermissions() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothAdvertise.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
  }

  @override
  void initState() {
    super.initState();

    handlePermissions();
    startScan();
  }

  void startScan() {
    flutterBlue.scanResults.listen((results) {
      setState(() {
        devices = results.map((result) => result.device).toList();
      });
    });

    flutterBlue.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beacon Scanner'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          print(devices[index].name);

          return ListTile(
            title: Text(devices[index].name),
            subtitle: Text(devices[index].id.toString()),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    flutterBlue.stopScan();
    super.dispose();
  }
}
