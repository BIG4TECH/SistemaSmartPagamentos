// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
import 'inicial/telaLogin.dart';
import '/screens/widgets/menuDrawer.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/charts/allCharts.dart';

class Home extends StatefulWidget {
  final String email;

  const Home({required this.email});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String tipoUser = '';
  String idUser = '';

  void _tipoUser(String email) async {
    var user = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    setState(() {
      tipoUser = user.docs.first['tipo_user'];
      idUser = user.docs.first.id;
    });
  }

  @override
  void initState() {
    //print('USER NO HOME: ${widget.tipoUser}');
    // TODO: implement initState
    super.initState();

    _tipoUser(widget.email);

    print('USER NO HOME: $tipoUser');
  }

  @override
  Widget build(BuildContext context) {
    if (tipoUser == '') {
      _tipoUser(widget.email);
    }

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
        backgroundColor: corPadrao(),
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
      drawer: menuDrawer(context, widget.email, tipoUser, idUser),
      body: tipoUser == ''
          ? Center(
              child: CircularProgressIndicator(
                color: corPadrao(),
              ),
            )
          : AllCharts(widget.email, tipoUser, idUser),
    );
  }
}
