import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';


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

  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
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
    if (selectedDateRange == null) return;

    DateTime start = selectedDateRange!.start;
    DateTime end = selectedDateRange!.end.add(Duration(hours: 23, minutes: 59, seconds: 59));

    final query = FirebaseFirestore.instance
        .collection('recebimentos')
        .where('id_user', isEqualTo: widget.idUser)
        .where('status', isEqualTo: 'ativo')
        .where('data_recebimento', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('data_recebimento', isLessThanOrEqualTo: Timestamp.fromDate(end));

    final snapshot = await query.get();
    setState(() {
      recebimentos = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      totalValor = recebimentos.fold(0.0, (sum, item) {
        double valor = item['valor'] is String
            ? double.tryParse(item['valor']) ?? 0.0
            : (item['valor'] as num).toDouble();
        return sum + valor;
      });
    });
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
              headers: ['Valor', 'Cliente', 'Produto', 'Tipo de Pagamento'],
              data: recebimentos.map((recebimento) {
                double valor = recebimento['valor'] is String
                    ? double.tryParse(recebimento['valor']) ?? 0.0
                    : (recebimento['valor'] as num).toDouble();
                return [
                  currencyFormat.format(valor),
                  recebimento['name'],
                  recebimento['nome_produto'],
                  recebimento['tipo_pagamento'] == 'banking_billet' ? 'Bolix' : 'Cartão',
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
          title: const Text(
            "Recebimentos",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
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
                    double valor = recebimento['valor'] is String
                        ? double.tryParse(recebimento['valor']) ?? 0.0
                        : (recebimento['valor'] as num).toDouble();
                    String formaPagamento = recebimento['tipo_pagamento'] == 'banking_billet' ? 'Bolix' : 'Cartão';
                    return Card(
                      child: ListTile(
                        title: Text("Valor: ${currencyFormat.format(valor)}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cliente: ${recebimento['name']}"),
                            Text("Produto: ${recebimento['nome_produto']}"),
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
                        "Total: ${currencyFormat.format(totalValor)}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}
