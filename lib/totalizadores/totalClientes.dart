import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
import 'package:smart_pagamento/screens/widgets/relatorios/cliRelatorio.dart';

class TotalClientes extends StatefulWidget {
  final String email;
  final String tipoUser;
  const TotalClientes(this.email, this.tipoUser);

  @override
  State<StatefulWidget> createState() => TotalClientesState();
}

class TotalClientesState extends State<TotalClientes> {
  int _quantClientes = 0;

  @override
  void initState() {
    super.initState();
    getDataClientes();
  }

  void getDataClientes() {
    widget.tipoUser == 'master' ?
    FirebaseFirestore.instance
        .collection('clientes')
        //.where('email_user', isEqualTo: widget.email)
        .snapshots()
        .listen((clientesSnapshot) {
      setState(() {
        _quantClientes = clientesSnapshot.size;
      });
    })
    :FirebaseFirestore.instance
        .collection('clientes')
        .where('email_user', isEqualTo: widget.email)
        .snapshots()
        .listen((clientesSnapshot) {
      setState(() {
        _quantClientes = clientesSnapshot.size;
      });
    });
  }

  Widget showLineChart() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: gradientBtn(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                '$_quantClientes',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clientes', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Quant. Total'),
            ],
          ),
          const SizedBox(width: 10),
          CliRelatorio(widget.email, widget.tipoUser)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showLineChart();
  }
}
