import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_pagamento/widgets/cores.dart';
import 'inicial/telaLogin.dart';
import '../widgets/menuDrawer.dart';
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
  bool isValid = false;
  bool isLoading = true;

  void _tipoUser(String email) async {
    try {
      var user = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      setState(() {
        tipoUser = user.docs.first['tipo_user'];
        idUser = user.docs.first.id;
        isValid = user.docs.first['is_valid'];
        isLoading = false;
      });

      if (!isValid) {
        // Redireciona para tela de login se o usuário não for válido
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      print("Erro ao obter tipo de usuário: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tipoUser(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: corPadrao()),
        ),
      );
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
      body: AllCharts(widget.email, tipoUser, idUser),
    );
  }
}
