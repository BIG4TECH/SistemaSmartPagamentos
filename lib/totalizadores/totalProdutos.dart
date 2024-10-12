import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
import 'package:smart_pagamento/screens/widgets/relatorios/prodRelatorio.dart';

class TotalProdutos extends StatefulWidget {
  final String email;
  final String tipoUser;
  const TotalProdutos(this.email, this.tipoUser);

  @override
  State<StatefulWidget> createState() => TotalProdutosState();
}

class TotalProdutosState extends State<TotalProdutos> {
  int _quantProdutos = 0;

  @override
  void initState() {
    super.initState();
    getDataProdutos();
  }

  void getDataProdutos() {
    
    widget.tipoUser == 'master' ? 
    FirebaseFirestore.instance
        .collection('products')
        //.where('email_user', isEqualTo: widget.email)
        .snapshots()
        .listen((produtos) {
      setState(() {
        _quantProdutos = produtos.size;
      });
    })
    : FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: widget.email)
        .snapshots()
        .listen((produtos) {
      setState(() {
        _quantProdutos = produtos.size;
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
                '$_quantProdutos',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Produtos', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Quant. Total'),
            ],
          ),
          const SizedBox(width: 10),
          ProdRelatorio(widget.email, widget.tipoUser)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showLineChart();
  }
}
