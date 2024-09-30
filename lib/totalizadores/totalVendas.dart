import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
import 'package:smart_pagamento/screens/widgets/relatorios/venRelatorio.dart';

class TotalVendas extends StatefulWidget {
  final String email;
  const TotalVendas(this.email);

  @override
  State<StatefulWidget> createState() => TotalVendasState();
}

class TotalVendasState extends State<TotalVendas> {
  int _quantVendas = 0;

  @override
  void initState() {
    super.initState();
    getDataVendas();
  }

  void getDataVendas() {
    FirebaseFirestore.instance
        .collection('vendas')
        .where('email_user', isEqualTo: widget.email)
        .snapshots()
        .listen((vendas) {
      setState(() {
        _quantVendas = vendas.size;
      });
    });
  }

  Widget showLineChart() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 0),
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
                '$_quantVendas',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vendas', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Quant. Total'),
            ],
          ),
          const SizedBox(width: 10),
          VenRelatorio(email: widget.email)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showLineChart();
  }
}
