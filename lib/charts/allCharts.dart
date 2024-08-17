import 'package:flutter/material.dart';

import 'ProdChart.dart';
import 'ProdVendChart.dart';
import 'lineChart.dart';
import '../totalizadores/totalClientes.dart';
import '../totalizadores/totalProdutos.dart';
import '../totalizadores/totalVendas.dart';
import '../totalizadores/totalVendidos.dart';
//import 'package:smart_pagamento/screens/widgets/relatorios/cliRelatorio.dart';

class AllCharts extends StatefulWidget {
  final String email;

   AllCharts(this.email);

  @override
  State<StatefulWidget> createState() => AllChartsState();
}

class AllChartsState extends State<AllCharts> {
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(32),
      child:  SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PieChartProd(widget.email),
                  const SizedBox(width: 20),
                  Prodchart(widget.email),
                ],
              ),
              const SizedBox(height: 20), // Espaçamento entre os gráficos
              LineChartSample1(widget.email),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TotalClientes(widget.email),
                  const SizedBox(width: 15),
                  TotalProdutos(widget.email),
                  const SizedBox(width: 15),
                  TotalVendas(widget.email),
                  const SizedBox(width: 15),
                  TotalVendidos(widget.email),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
