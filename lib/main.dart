import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_pagamento/verify.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
  MaterialApp(
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [
      Locale('pt', 'BR'),
      Locale('en', 'US'), // Outros idiomas suportados (opcional)
    ],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    debugShowCheckedModeBanner: false,
    home: VerifyState(), // Certifique-se de que está apontando para a tela inicial correta
  


    
  ));
}
