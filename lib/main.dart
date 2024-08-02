import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/listas/telaLogin.dart';
import 'firebase_options.dart';
import 'package:smart_pagamento/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Home()));
}
