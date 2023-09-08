import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:indoor_nav/auth_screen.dart';
import 'package:indoor_nav/home_page.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;

  await dotenv.load(fileName: ".env");
  await [Permission.location, Permission.storage, Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request().then(
    (status) {
      runApp(
        MaterialApp(
          home: user == null ? SignInPage() : const HomeScreen(),
        ),
      );
    },
  );
}
