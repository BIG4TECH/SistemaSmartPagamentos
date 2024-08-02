import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CliRelatorio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () async {
          await generateAndPrintPdf(context);
        },
        icon: const Icon(Icons.picture_as_pdf_rounded),
        tooltip: 'Gerar Relatório',
      ),
    );
  }
}

Future<void> generateAndPrintPdf(BuildContext context) async {
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  List<Map<String, dynamic>> clientes = [];

  final pdf = pw.Document();

  // Buscar clientes do Firestore
  final collection = FirebaseFirestore.instance.collection('clientes');
  final querySnapshot = await collection.get();

  // Buscar vendas do Firestore
  final vendas = FirebaseFirestore.instance.collection('vendas');
  final queryVendas = await vendas.get();

  // Buscar iven do Firestore
  final iven = FirebaseFirestore.instance.collection('itens_vendas');
  final queryIven = await iven.get();

  for (var datacliente in querySnapshot.docs) {
    int quantvendas = 0;
    num quantiven = 0;

    for (var datavendas in queryVendas.docs) {
      if (datavendas['idcliente'] == datacliente.id) {
        quantvendas++;

        for (var dataiven in queryIven.docs) {
          if (dataiven['idvenda'] == datavendas.id) {
            var aux = dataiven['quantidade'];
            quantiven += aux;
          }
        }
      }
    }

    Map<String, dynamic> novoCliente = {
      'name': datacliente['name'],
      'whatsapp': datacliente['whatsapp'],
      'email': datacliente['email'],
      'quantvendas': quantvendas,
      'quantiven': quantiven
    };

    // Adicionando o novo cliente à lista
    clientes.add(novoCliente);
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
            pw.Text('Relatório de Clientes', style: titleStyle),
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
                'Whatsapp',
                'Email',
                'Quant. Compras',
                'Quant. Produtos'
              ], // Cabeçalhos das colunas
              data: clientes.map((item) {
                return [
                  item['name'],
                  item['whatsapp'].toString(),
                  item['email'],
                  item['quantvendas'],
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
    
  

    // Dividir a lista em páginas
    int itemsPerPage = 15; // Defina quantos itens deseja por página
    for (int i = 0; i < clientes.length; i += itemsPerPage) {
      var vendasPage = clientes.sublist(
          i, i + itemsPerPage > clientes.length ? clientes.length : i + itemsPerPage);
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
