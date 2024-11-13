import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/presentation/resources/app_resources.dart';
import '/presentation/widgets/indicator.dart';

class PieChartProd extends StatefulWidget {
  final String email;
  final String tipoUser;
  final String idUser;
  final String? emailFiliado;
  final String? idFiliado;

  const PieChartProd(this.email, this.tipoUser, this.idUser, this.emailFiliado,
      this.idFiliado);

  @override
  State<StatefulWidget> createState() => PieChartProdState();
}

class PieChartProdState extends State<PieChartProd> {
  int touchedIndex = -1;
  int _quantidadeTotal = 0;
  List<DadosProduto> _listProdutosEscolhidos = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder<List<DadosProduto>>(
      future: getDataProductsPie(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        _listProdutosEscolhidos = snapshot.data!;
        _quantidadeTotal = _listProdutosEscolhidos.fold(
            0, (sum, item) => sum + (item.quantidade ?? 0));

        return showPieProdutosVendidos(size);
      },
    );
  }

  Widget showPieProdutosVendidos(Size size) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
       
        children: [
          const SizedBox(
            height: 10,
          ),
           Text(
            'Quantidade de produtos mais vendidos no mês',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width <= 720 ? 14 : 18),
          ),
          Container(
            //color: Colors.amber,
           
            height: 200,
            width: 430,
            child: Row(
              children: <Widget>[
                const SizedBox(height: 18),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: size.width <= 720 ? 15 : 40,
                      sections: showingSections(),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Indicator(
                      color: AppColors.contentColorBlue,
                      text: _listProdutosEscolhidos.isNotEmpty
                          ? _listProdutosEscolhidos[0].nome ?? ''
                          : '',
                      isSquare: true,
                    ),
                    const SizedBox(height: 4),
                    _listProdutosEscolhidos.length > 1
                        ? Indicator(
                            color: AppColors.contentColorYellow,
                            text: _listProdutosEscolhidos[1].nome ?? '',
                            isSquare: true,
                          )
                        : const SizedBox(),
                    const SizedBox(height: 4),
                    _listProdutosEscolhidos.length > 2
                        ? Indicator(
                            color: AppColors.contentColorPurple,
                            text: _listProdutosEscolhidos[2].nome ?? '',
                            isSquare: true,
                          )
                        : const SizedBox(),
                    const SizedBox(height: 4),
                    _listProdutosEscolhidos.length > 3
                        ? Indicator(
                            color: AppColors.contentColorGreen,
                            text: _listProdutosEscolhidos[3].nome ?? '',
                            isSquare: true,
                          )
                        : const SizedBox(),
                    const SizedBox(height: 18),
                  ],
                ),
                const SizedBox(width: 28),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<List<DadosProduto>> getDataProductsPie() async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));

    var vendas;

    if (widget.tipoUser == 'master') {
      if (widget.emailFiliado == null) {
        vendas = await FirebaseFirestore.instance.collection('vendas').get();
      } else {
        vendas = await FirebaseFirestore.instance
            .collection('vendas')
            .where('id_user', isEqualTo: widget.idFiliado)
            .get();
      }
    } else {
      vendas = await FirebaseFirestore.instance
          .collection('vendas')
          .where('id_user', isEqualTo: widget.idUser)
          .get();
    }

    vendas = vendas.docs.where((doc) {
      DateTime dataVenda =
          DateFormat("dd/MM/yyyy").parse(doc['first_execution']);
      return dataVenda.isAfter(firstDayOfMonth.subtract(Duration(days: 1))) &&
          dataVenda.isBefore(lastDayOfMonth.add(Duration(days: 1)));
    }).toList();

    var produtos;
    if (widget.tipoUser == 'master') {
      if (widget.emailFiliado == null) {
        produtos =
            await FirebaseFirestore.instance.collection('products').get();
      } else {
        produtos = await FirebaseFirestore.instance
            .collection('products')
            .where('email_user', isEqualTo: widget.emailFiliado)
            .get();
      }
    } else {
      produtos = await FirebaseFirestore.instance
          .collection('products')
          .where('email_user', isEqualTo: widget.email)
          .get();
    }

    Map<String, DadosProduto> produtosEscolhidosMap = {};
    _quantidadeTotal = 0;

    for (var docvenda in vendas) {
      for (var docprod in produtos.docs) {
        int quantidade = 0;

        if (docvenda['plan']['id'] == docprod['plan_id']) {
          quantidade++;
        }

        if (quantidade > 0) {
          _quantidadeTotal += quantidade;
          if (produtosEscolhidosMap.containsKey(docprod.id)) {
            produtosEscolhidosMap[docprod.id]!.quantidade =
                (produtosEscolhidosMap[docprod.id]!.quantidade ?? 0) +
                    quantidade;
          } else {
            produtosEscolhidosMap[docprod.id] = DadosProduto(
              nome: docprod['name'],
              quantidade: quantidade,
              id: docprod.id,
            );
          }
        }
      }
    }

    List<DadosProduto> produtosEscolhidos =
        produtosEscolhidosMap.values.toList();
    produtosEscolhidos.sort((a, b) => b.quantidade!.compareTo(a.quantidade!));

    return produtosEscolhidos;
  }

  List<PieChartSectionData> showingSections() {
    if (_listProdutosEscolhidos.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: 'No Data',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ];
    }

    return List.generate(
      _listProdutosEscolhidos.length > 4 ? 4 : _listProdutosEscolhidos.length,
      (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 60.0 : 50.0;
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

        return PieChartSectionData(
          color: _getColor(i),
          value: ((_listProdutosEscolhidos[i].quantidade ?? 0) * 100) /
              _quantidadeTotal,
          title: _listProdutosEscolhidos[i].quantidade.toString(),
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        );
      },
    );
  }

  Color _getColor(int index) {
    switch (index) {
      case 0:
        return AppColors.contentColorBlue;
      case 1:
        return AppColors.contentColorYellow;
      case 2:
        return AppColors.contentColorPurple;
      case 3:
        return AppColors.contentColorGreen;
      default:
        return Colors.grey;
    }
  }
}

class DadosProduto {
  String? nome;
  int? quantidade;
  String? id;

  DadosProduto({this.nome, this.quantidade, this.id});
}
