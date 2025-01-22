import 'package:cloud_firestore/cloud_firestore.dart';
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

  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

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
      if (selectedDateRange == null) return;

      DateTime start = selectedDateRange!.start;
      DateTime end = selectedDateRange!.end
          .add(Duration(hours: 23, minutes: 59, seconds: 59));

      final vendasSnapshot = await FirebaseFirestore.instance
          .collection('vendas')
          .where('id_user', isEqualTo: widget.idUser)
          .where('status', isNotEqualTo: 'canceled')
          .get();

      print('PEGOU VENDAS: ${vendasSnapshot.docs.length}');

      for (var venda in vendasSnapshot.docs) {
        var periodoRecorrencia = venda['plan']['interval'];

        String dataUltimoPagamentoString = venda['first_execution'];

        DateTime dataUltimoPagamento =
            DateFormat("dd/MM/yyyy").parse(dataUltimoPagamentoString);

        DateTime? dataRecebimento;

        switch (periodoRecorrencia) {
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
        if (dataRecebimento!.isAtSameMomentAs(start) ||
            dataRecebimento.isAtSameMomentAs(end) ||
            (dataRecebimento.isAfter(start) && dataRecebimento.isBefore(end))) {
          recebimentos.add(venda.data());

          totalValor = recebimentos.fold(0.0, (sum, item) {
            double valor = item['total'] is String
                ? double.tryParse(item['total']) ?? 0.0
                : (item['total'] as num).toDouble();
            return sum + valor;
          });
        }
      }

      setState(() {});
    } catch (e) {
      print(e);
    }

    /*
    setState(() {
      recebimentos = recebimentosSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      totalValor = recebimentos.fold(0.0, (sum, item) {
        double valor = item['valor'] is String
            ? double.tryParse(item['valor']) ?? 0.0
            : (item['valor'] as num).toDouble();
        return sum + valor;
      });
    });
    */
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
                      ? 'Boleto/Pix' :
                      'Cartão',
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title:  Text(
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
