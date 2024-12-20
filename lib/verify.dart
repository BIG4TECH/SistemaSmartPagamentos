import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_pagamento/screens/home.dart';
import 'package:smart_pagamento/screens/inicial/telaLogin.dart';

class VerifyState extends StatefulWidget {
  @override
  State<VerifyState> createState() => _verifyState();
}

class _verifyState extends State<VerifyState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User? user = snapshot.data;
          return Home(email: user!.email.toString());
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }
        return snapshot.connectionState == ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : LoginScreen();
      },
    );
  }
}
