// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'inicial/telaLogin.dart';
import '/screens/widgets/menuDrawer.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/charts/allCharts.dart';

class Home extends StatefulWidget {
  final String email;

  const Home(this.email);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            )),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(89, 19, 165, 1.0),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: Icon(Icons.logout),
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Deseja realmente sair?'),
                        //content: Text('Deseja realmente sair?'),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancelar')),
                          TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              },
                              child: Text('Confirmar')),
                        ],
                      ));
            },
          ),
        ],
      ),
      drawer: menuDrawer(context, widget.email),
      body: AllCharts(widget.email),
    );
  }
}
