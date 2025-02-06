import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smart_pagamento/widgets/cores.dart';
import 'package:smart_pagamento/widgets/editarNumero.dart';

class RecebimentosRelatorio extends StatefulWidget {
  final String email;
  final String idUser;
  const RecebimentosRelatorio(this.email, this.idUser);

  @override
  State<StatefulWidget> createState() => _RecebimentosRelatorioState();
}

class _RecebimentosRelatorioState extends State<RecebimentosRelatorio> {
  DateTimeRange? selectedDateRange;
  List<Map<String, dynamic>> recebimentos = [];
  double totalValor = 0.0;
  List<String> _listProdutoDrop = [];
  String? _dadosProduto;
  String _idProduto = '';
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

  Future<void> _fetchProdutoName() async {
    List<String> produtos = await _setListProduto();
    setState(() {
      _listProdutoDrop = produtos;
    });
  }

  Future<List<String>> _setListProduto() async {
    var produtos = await FirebaseFirestore.instance
        .collection('products')
        .where('status', isEqualTo: 'ativo')
        .get();

    return produtos.docs.map((doc) {
      return '${doc['name']}-${doc.id}';
    }).toList();
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt'),
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      _fetchRecebimentos();
    }
  }

  Future<void> _fetchRecebimentos() async {
    try {
      print('CHEGOU NO RECEBIMENTOS');

      if (selectedDateRange == null) {
        // Caso ainda não tenha um intervalo definido, assume os próximos 30 dias
        selectedDateRange = DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(Duration(days: 30)),
        );
      }

      DateTime start = selectedDateRange!.start;
      DateTime end = selectedDateRange!.end
          .add(Duration(hours: 23, minutes: 59, seconds: 59));

      final vendasSnapshot = _idProduto == ''
          ? await FirebaseFirestore.instance
              .collection('vendas')
              .where('id_user', isEqualTo: widget.idUser)
              .where('status', isNotEqualTo: 'canceled')
              .get()
          : await FirebaseFirestore.instance
              .collection('vendas')
              .where('id_user', isEqualTo: widget.idUser)
              .where('status', isNotEqualTo: 'canceled')
              .where('plan', isEqualTo: _idProduto)
              .get();

      print('PEGOU VENDAS: ${vendasSnapshot.docs.length}');

      recebimentos
          .clear(); // Garante que a lista não acumule resultados repetidos

      String recorString = '';

      for (var venda in vendasSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(venda['plan'])
            .get()
            .then((v) => recorString = v['recurrencePeriod']);

        num? periodoRecorrencia;

        switch (recorString) {
          case 'semanal':
            periodoRecorrencia = 0.25;
            break;
          case 'quinzenal':
            periodoRecorrencia = 0.5;
            break;
          case 'mensal':
            periodoRecorrencia = 1;
            break;
          case 'bimestral':
            periodoRecorrencia = 2;
            break;
          case 'trimestral':
            periodoRecorrencia = 3;
            break;
          case 'semestral':
            periodoRecorrencia = 6;
            break;
          case 'anual':
            periodoRecorrencia = 12;
            break;
          default:
            periodoRecorrencia = 0;
            break;
        }

        String dataUltimoPagamentoString = venda['first_execution'];

        DateTime dataUltimoPagamento =
            DateTime.parse(dataUltimoPagamentoString);

        DateTime? dataRecebimento;

        switch (periodoRecorrencia) {
          case 0.25:
            dataRecebimento = DateTime(dataUltimoPagamento.year,
                dataUltimoPagamento.month, dataUltimoPagamento.day + 7);
            break;
          case 0.5:
            dataRecebimento = DateTime(dataUltimoPagamento.year,
                dataUltimoPagamento.month + 1, dataUltimoPagamento.day + 15);
            break;
          case 1:
            dataRecebimento = DateTime(dataUltimoPagamento.year,
                dataUltimoPagamento.month + 1, dataUltimoPagamento.day);
            break;
          case 2:
            dataRecebimento = DateTime(dataUltimoPagamento.year,
                dataUltimoPagamento.month + 2, dataUltimoPagamento.day);
            break;
          case 3:
            dataRecebimento = DateTime(dataUltimoPagamento.year,
                dataUltimoPagamento.month + 3, dataUltimoPagamento.day);
            break;
          case 6:
            dataRecebimento = DateTime(dataUltimoPagamento.year,
                dataUltimoPagamento.month + 6, dataUltimoPagamento.day);
            break;
          case 12:
            dataRecebimento = DateTime(dataUltimoPagamento.year,
                dataUltimoPagamento.month + 12, dataUltimoPagamento.day);
            break;
          default:
            break;
        }

        print('DATA PROXIMO PAGAMENTO $dataRecebimento');

        if (dataRecebimento != null &&
            (dataRecebimento.isAtSameMomentAs(start) ||
                dataRecebimento.isAtSameMomentAs(end) ||
                (dataRecebimento.isAfter(start) &&
                    dataRecebimento.isBefore(end)))) {
          recebimentos.add(venda.data());
        }
      }

      totalValor = recebimentos.fold(0.0, (sum, item) {
        double valor = item['total'] is String
            ? double.tryParse(item['total']) ?? 0.0
            : (item['total'] as num).toDouble();
        return sum + valor;
      });

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text("Relatório de Próximos Recebimentos"),
            pw.SizedBox(height: 10),
            pw.Text(
                "Período: ${dateFormat.format(selectedDateRange!.start)} - ${dateFormat.format(selectedDateRange!.end)}"),
            pw.Text("Soma Total: ${currencyFormat.format(totalValor)}"),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Valor', 'Cliente', 'Tipo de Pagamento'],
              data: recebimentos.map((recebimento) {
                double valor = recebimento['total'] is String
                    ? double.tryParse(recebimento['total']) ?? 0.0
                    : (recebimento['total'] as num).toDouble();
                return [
                  currencyFormat.format(valor),
                  recebimento['name'],
                  //recebimento['nome_produto'],
                  recebimento['payment'] == 'banking_billet'
                      ? 'Boleto/Pix'
                      : 'Cartão',
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  void initState() {
    super.initState();

    _fetchProdutoName();

    selectedDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: 30)),
    );

    _fetchRecebimentos();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Recebimentos",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size.width <= 720 ? 24 : 38,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: recebimentos.isNotEmpty ? _generatePDF : null,
            ),
          ],
          centerTitle: true,
          backgroundColor: corPadrao(),
        ),
        body: Container(
          padding: size.width <= 720
              ? const EdgeInsets.only(top: 40, left: 10, right: 10)
              : const EdgeInsets.only(top: 40, left: 50, right: 50),
          child: Column(
            children: [
              Row(children: [
                TextButton(
                  onPressed: () => _pickDateRange(context),
                  child: Text(
                    selectedDateRange == null
                        ? 'Selecione o Período'
                        : 'Período: ${dateFormat.format(selectedDateRange!.start)} - ${dateFormat.format(selectedDateRange!.end)}',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
                Expanded(
                  child: DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSelectedItems: true,
                      showSearchBox: true,
                    ),
                    items: _listProdutoDrop
                        .map((String item) => item.split('-')[0])
                        .toList(),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Selecione um produto",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                    ),
                    onChanged: (String? prodSelecionado) async {
                      setState(() {
                        _dadosProduto = prodSelecionado!.split('-')[0];
                        _idProduto = prodSelecionado.split('-')[1];
                      });

                      setState(() {});
                    },
                    selectedItem: _dadosProduto,
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
                      setState(() {
                        _idProduto = '';
                        _dadosProduto = null;
                      });

                      _fetchRecebimentos();
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
              Expanded(
                child: ListView.builder(
                  itemCount: recebimentos.length,
                  itemBuilder: (context, index) {
                    final recebimento = recebimentos[index];
                    double valor = recebimento['total'] is String
                        ? double.tryParse(recebimento['total']) ?? 0.0
                        : (recebimento['total'] as num).toDouble();
                    String formaPagamento =
                        recebimento['payment'] == 'banking_billet'
                            ? 'Boleto/Pix'
                            : 'Cartão';
                    return Card(
                      child: ListTile(
                        title: Text(
                            "Valor: R\$ ${formatWithComma(int.parse(valor.toString()))}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cliente: ${recebimento['name']}"),
                            //Text("Produto: ${recebimento['nome_produto']}"),
                            Text("Pagamento: $formaPagamento"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (totalValor > 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Total: R\$ ${formatWithComma(int.parse(totalValor.toString()))}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}
