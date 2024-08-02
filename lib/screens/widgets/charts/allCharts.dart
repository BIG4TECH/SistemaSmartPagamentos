import 'package:flutter/material.dart';

import 'ProdChart.dart';
import 'ProdVendChart.dart';
import 'lineChart.dart';
import 'totalClientes.dart';
import 'totalProdutos.dart';
import 'totalVendas.dart';
import 'totalVendidos.dart';
import 'package:smart_pagamento/screens/widgets/relatorios/cliRelatorio.dart';

class AllCharts extends StatefulWidget {
  const AllCharts({super.key});

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
      child: const SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PieChartProd(),
                  SizedBox(width: 20),
                  Prodchart(),
                ],
              ),
              SizedBox(height: 20), // Espaçamento entre os gráficos
              LineChartSample1(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TotalClientes(),
                  SizedBox(width: 15),
                  TotalProdutos(),
                  SizedBox(width: 15),
                  TotalVendas(),
                  SizedBox(width: 15),
                  TotalVendidos(),
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
