import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';

import '../totalizadores/totalClientes.dart';
import '../totalizadores/totalProdutos.dart';
import '../totalizadores/totalVendas.dart';
import '../totalizadores/totalVendidos.dart';
import 'ProdChart.dart';
import 'ProdVendChart.dart';
import 'lineChart.dart';
//import 'package:smart_pagamento/screens/widgets/relatorios/cliRelatorio.dart';

class AllCharts extends StatefulWidget {
  final String email;
  final String tipoUser;
  AllCharts(this.email, this.tipoUser);

  @override
  State<StatefulWidget> createState() => AllChartsState();
}

class AllChartsState extends State<AllCharts> {
  int touchedIndex = -1;
  String? _dadosFiliado;
  String? _filiadoId;
  List<String> _listFiliadoDrop = [];

  Future<void> _fetchFiliadoData() async {
    setState(() async {
      _listFiliadoDrop = await _setListFiliado();
    });
  }

  Future<List<String>> _setListFiliado() async {
    var filiados = await FirebaseFirestore.instance
        .collection('users')
        .where('tipo_user', isEqualTo: 'filiado')
        .get();

    List<String> listFiliados = [];

    setState(() {
      listFiliados = filiados.docs.map((doc) {
        return '${doc['name']} | ${doc['email']}';
      }).toList();
    });

    await Future.delayed(Duration(seconds: 1));

    return listFiliados;
  }

  Future<String?> fetchAndSetIdFiliado(String? filiSelecionado) async {
    String? idFiliado;
    var filiados = await FirebaseFirestore.instance
        .collection('users')
        .where('tipo_user', isEqualTo: 'filiado')
        .get();

    for (var filiado in filiados.docs) {
      if (filiSelecionado == '${filiado['name']} | ${filiado['email']}') {
        idFiliado = filiado.id;
        break;
      }
    }
    return idFiliado;
  }

  @override
  void initState() {
    super.initState();

    _fetchFiliadoData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(
        left: size.width * 0.07,
        right: size.width * 0.07,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          showSelectedItems: true,
                          showSearchBox: true,
                        ),
                        items: _listFiliadoDrop,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText:
                                "Selecione um filiado para filtrar os dados",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                            ),
                          ),
                        ),
                        onChanged: (String? cliSelecionado) async {
                          setState(() {
                            _dadosFiliado = cliSelecionado;
                          });
                          _filiadoId =
                              await fetchAndSetIdFiliado(cliSelecionado);
                          setState(() {});
                        },
                        selectedItem: _dadosFiliado,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.045,
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientBtn(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _filiadoId = '';
                          _dadosFiliado = '';
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          minimumSize: Size(40,
                              40), // Garantir que o botão ocupe o tamanho do Container
                          padding: EdgeInsets
                              .zero, // Remover padding para centralizar o ícone
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Icon(
                          Icons.clear_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]),

              const SizedBox(height: 20),
              size.width <= 720
                  ? Column(
                      children: [
                        PieChartProd(widget.email, widget.tipoUser, _filiadoId),
                        const SizedBox(height: 20),
                        Prodchart(widget.email, widget.tipoUser, _filiadoId),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PieChartProd(widget.email, widget.tipoUser, _filiadoId),
                        const SizedBox(width: 20),
                        Prodchart(widget.email, widget.tipoUser, _filiadoId),
                      ],
                    ),
              const SizedBox(height: 20), // Espaçamento entre os gráficos
              LineChartSample1(widget.email, widget.tipoUser, _filiadoId),
              const SizedBox(height: 20),
              size.width <= 720
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TotalClientes(
                            widget.email, widget.tipoUser, _filiadoId),
                        const SizedBox(height: 15),
                        TotalProdutos(
                            widget.email, widget.tipoUser, _filiadoId),
                        const SizedBox(height: 15),
                        TotalVendas(widget.email, widget.tipoUser, _filiadoId),
                        const SizedBox(height: 15),
                        TotalVendidos(
                            widget.email, widget.tipoUser, _filiadoId),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TotalClientes(
                            widget.email, widget.tipoUser, _filiadoId),
                        const SizedBox(width: 15),
                        TotalProdutos(
                            widget.email, widget.tipoUser, _filiadoId),
                        const SizedBox(width: 15),
                        TotalVendas(widget.email, widget.tipoUser, _filiadoId),
                        const SizedBox(width: 15),
                        TotalVendidos(
                            widget.email, widget.tipoUser, _filiadoId),
                      ],
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
