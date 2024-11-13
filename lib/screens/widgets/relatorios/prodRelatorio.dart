//import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
//import 'package:share_plus/share_plus.dart';
import 'package:smart_pagamento/screens/widgets/editarNumero.dart';

class ProdRelatorio extends StatelessWidget {
  final String email;
  final String tipoUser;
  final String idUser;
  final String? emailFiliado;
  final String? idUserFiliado;
  ProdRelatorio(this.email, this.tipoUser, this.idUser, this.emailFiliado,
      this.idUserFiliado);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Center(
      child: IconButton(
        onPressed: () async {
          await generateAndPrintPdf(context, email, tipoUser, emailFiliado,
              idUser, idUserFiliado, size);
        },
        icon: const Icon(Icons.picture_as_pdf_rounded),
        tooltip: 'Gerar Relatório',
      ),
    );
  }
}

Future<void> generateAndPrintPdf(
    BuildContext context,
    String email,
    String tipoUser,
    String? emailFiliado,
    String idUser,
    String? idUserFiliado,
    Size size) async {
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  List<Map<String, dynamic>> products = [];

  final pdf = pw.Document();

  // Buscar produtos do Firestore
  final collection = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('products')
          : FirebaseFirestore.instance
              .collection('products')
              .where('email_user', isEqualTo: emailFiliado))
      : FirebaseFirestore.instance
          .collection('products')
          .where('email_user', isEqualTo: email);

  final querySnapshot = await collection.get();

  // Buscar produtos do Firestore
  final vendas = tipoUser == 'master'
      ? (emailFiliado == null
          ? FirebaseFirestore.instance.collection('vendas')
          : FirebaseFirestore.instance
              .collection('vendas')
              .where('id_user', isEqualTo: idUserFiliado))
      : FirebaseFirestore.instance
          .collection('vendas')
          .where('id_user', isEqualTo: idUser);

  final vendasSnapshot = await vendas.get();

  // Processar dados de produtos e itens vendidos
  for (var dataProducts in querySnapshot.docs) {
    num quantiven = 0;

    for (var dataVendas in vendasSnapshot.docs) {
      if (dataProducts['plan_id'] == dataVendas['plan']['id']) {
        quantiven++;
      }
    }

    // Adiciona o produto à lista, evitando duplicatas
    if (products.indexWhere((prod) => prod['name'] == dataProducts['name']) ==
        -1) {
      String recur = '';
      switch (dataProducts['recurrencePeriod']) {
        case 1:
          recur = 'Mensal';
          break;
        case 2:
          recur = 'Bimestral';
          break;
        case 3:
          recur = 'Trimestral';
          break;
        case 6:
          recur = 'Semestral';
          break;
        case 12:
          recur = 'Anual';
          break;
        default:
      }

      Map<String, dynamic> novoProduto = {
        'name': dataProducts['name'],
        'price':
            'R\$ ${formatWithComma(int.parse(formatarNumero(double.parse(dataProducts['price'].toString()))))}',
        //'desconto': '${dataProducts['desconto']}%',
        'recurrencePeriod': recur,
        'paymentOption': dataProducts['paymentOption'],
        'quantiven': quantiven
      };

      // Adicionando o novo produto à lista
      products.add(novoProduto);
    }
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
  pw.Widget buildPage(List<Map<String, dynamic>> vendas, bool showH) {
    pw.Column showHeader() {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relatório de Produtos',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text('Quantidade Total de Produtos: ${products.length}',
                style: headerStyle),
            pw.SizedBox(height: 5),
            // Linha horizontal
            pw.Container(
              height: 2,
              color: PdfColors.grey,
              width: double.infinity,
            ),
            pw.SizedBox(height: 20),
          ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        showH ? showHeader() : pw.SizedBox(),
        pw.TableHelper.fromTextArray(
          headers: [
            'Nome',
            'Valor',
            'Recorrência',
            'Forma de Pagamento',
            'Quant. Vendidos'
          ],
          data: vendas.map((item) {
            return [
              item['name'],
              item['price'],
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
    bool showH = i < itemsPerPage;
    var vendasPage = products.sublist(
        i,
        i + itemsPerPage > products.length
            ? products.length
            : i + itemsPerPage);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => buildPage(vendasPage, showH),
      ),
    );
  }

  if (size.width <= 720) {
    final pdfBytes = await pdf.save();
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Cria um link temporário para download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "relatorio.pdf")
      ..click();

    // Revoga o objeto URL após o download
    html.Url.revokeObjectUrl(url);
  } else {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
