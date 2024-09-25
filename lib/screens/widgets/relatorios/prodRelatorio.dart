import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProdRelatorio extends StatelessWidget {
  final String email;

  ProdRelatorio(this.email);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () async {
          await generateAndPrintPdf(context, email);
        },
        icon: const Icon(Icons.picture_as_pdf_rounded),
        tooltip: 'Gerar Relatório',
      ),
    );
  }
}

Future<void> generateAndPrintPdf(BuildContext context, String email) async {
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  List<Map<String, dynamic>> products = [];

  final pdf = pw.Document();

  // Buscar clientes do Firestore
  final collection = FirebaseFirestore.instance.collection('products').where('email_user', isEqualTo: email);
  final querySnapshot = await collection.get();

  // Buscar iven do Firestore
  final iven = FirebaseFirestore.instance.collection('itens_vendas').where('email_user', isEqualTo: email);
  final queryIven = await iven.get();

  for (var dataProducts in querySnapshot.docs) {
    num quantiven = 0;

    for (var dataiven in queryIven.docs) {
      if (dataiven['idproduto'] == dataProducts.id) {
        var aux = dataiven['quantidade'];
        quantiven += aux;
      }
    }
    String recur = '';

    switch (dataProducts['recurrencePeriod']) {
      case 30:
        recur = 'Mensal';
        break;
      case 60:
        recur = 'Bimestral';
        break;
      case 90:
        recur = 'Trimestral';
        break;
      default:
    }

    Map<String, dynamic> novoProduto = {
      'name': dataProducts['name'],
      'price': 'R\$ ${dataProducts['price']}',
      'desconto': '${dataProducts['desconto']}%',
      'recurrencePeriod': recur,
      'paymentOption': dataProducts['paymentOption'],
      'quantiven': quantiven
    };

    // Adicionando o novo cliente à lista
    products.add(novoProduto);
  }

  // Estilos
  final pw.TextStyle titleStyle = pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue,
  );

  final pw.TextStyle headerStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle contentStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  final pw.TextStyle subtitleStyle = pw.TextStyle(
    fontSize: 12,
    color: PdfColors.black,
  );

  // Adicionar dados ao PDF
  pw.Widget buildPage(List<Map<String, dynamic>> vendas) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Relatório de Produtos', style: titleStyle),
        pw.SizedBox(height: 5),

        // Linha horizontal
        pw.Container(
          height: 2,
          color: PdfColors.grey,
          width: double.infinity,
        ),
        pw.SizedBox(height: 20),

        pw.TableHelper.fromTextArray(
          headers: [
            'Nome',
            'Preço (U)',
            'Desconto (%)',
            'Recorrência',
            'Forma de Pagamento',
            'Quant. Vendidos'
          ], // Cabeçalhos das colunas
          data: products.map((item) {
            return [
              item['name'],
              item['price'],
              item['desconto'],
              item['recurrencePeriod'],
              item['paymentOption'],
              item['quantiven']
            ];
          }).toList(),
          headerStyle: headerStyle,
          cellStyle: contentStyle,
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 10),

        // Linha horizontal
        pw.Container(
          height: 2,
          color: PdfColors.grey,
          width: double.infinity,
        ),

        pw.SizedBox(height: 10),

        // Rodapé
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Desenvolvido por BIG4TECH', style: subtitleStyle),
            pw.Text(formatoData.format(datahora), style: subtitleStyle),
          ],
        ),
      ],
    );
  }

  int itemsPerPage = 15;

  for (int i = 0; i < products.length; i += itemsPerPage) {
    var vendasPage = products.sublist(
        i,
        i + itemsPerPage > products.length
            ? products.length
            : i + itemsPerPage);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => buildPage(vendasPage),
      ),
    );
  }

  // Exibir e imprimir o PDF na web
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}