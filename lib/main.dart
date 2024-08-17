import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_pagamento/verify.dart';
import 'screens/inicial/telaLogin.dart';
import 'firebase_options.dart';
import 'package:smart_pagamento/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MaterialApp(debugShowCheckedModeBanner: false, home: VerifyState()));
}
