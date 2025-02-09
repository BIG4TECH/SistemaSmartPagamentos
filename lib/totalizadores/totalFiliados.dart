import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/widgets/cores.dart';
import 'package:smart_pagamento/widgets/relatorios/cliRelatorio.dart';

class TotalClientes extends StatefulWidget {
  final String email;
  final String tipoUser;
  final String idUser;
  final String? emailFiliado;
  final String? idFiliado;
  const TotalClientes(this.email, this.tipoUser, this.idUser, this.emailFiliado,
      this.idFiliado);

  @override
  State<StatefulWidget> createState() => TotalClientesState();
}

class TotalClientesState extends State<TotalClientes> {
  Stream<QuerySnapshot> _getClientesStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('tipo_user', isEqualTo: 'filiado')
        .snapshots();
  }

  Widget showLineChart(int quantClientes) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
                    '$quantClientes',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filiados',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Quant. Total'),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
          CliRelatorio(widget.email, widget.tipoUser, widget.idUser,
              widget.emailFiliado, widget.idFiliado)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getClientesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: corPadrao(),
          );
        }
        if (snapshot.hasError) {
          return Text('Erro.');
        }

        int quantClientes = snapshot.data!.size;
        return showLineChart(quantClientes);
      },
    );
  }
}
