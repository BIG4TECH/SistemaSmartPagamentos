import 'dart:io';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
//import 'package:share_plus/share_plus.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
import 'package:smart_pagamento/screens/widgets/editarNumero.dart';

class VenRelatorio extends StatelessWidget {
  final String? clienteid;
  final String? emailFiliado;
  final String? idFiliado;
  String dadosCliente = '';
  DateTimeRange? selectedDateRange;
  final String? email;
  final String idUser;
  final String tipoUser;

  VenRelatorio(
      {this.clienteid,
      this.email,
      required this.tipoUser,
      required this.emailFiliado,
      required this.idFiliado,
      required this.idUser});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Center(
      child: IconButton(
        onPressed: () async {
          showDialogCliente(context, dadosCliente, selectedDateRange,
              email ?? '', tipoUser, idUser, emailFiliado, idFiliado, size);
        },
        icon: const Icon(Icons.picture_as_pdf_rounded),
        tooltip: 'Gerar $email',
      ),
    );
  }
}

void showDialogCliente(
    BuildContext context,
    String dadosCliente,
    DateTimeRange? selectedDateRange,
    String email,
    String tipoUser,
    String idUser,
    String? emailFiliado,
    String? idFiliado,
    Size size) async {
  dadosCliente = '';
  String? cliid = '';

  List<String> listCliente =
      await _setListCliente(email, tipoUser, idUser, emailFiliado, idFiliado);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: const Text(
            "Filtro",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          scrollable: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CLIENTE
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                    showSelectedItems: true, showSearchBox: true),
                items: listCliente,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    labelText: "Cliente",
                    hintText: "Selecione um dos clientes.",
                  ),
                ),
                onChanged: (String? cliSelecionado) async {
                  setState(() {
                    dadosCliente = cliSelecionado.toString();
                  });
                  cliid = await fetchAndSetIdCliente(cliSelecionado, email,
                      tipoUser, emailFiliado, idFiliado, idUser);
                },
                selectedItem: dadosCliente,
              ),
              const SizedBox(height: 20),

              // INTERVALO DE DATAS
              ElevatedButton(
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (picked != null && picked != selectedDateRange) {
                    setState(() {
                      selectedDateRange = picked;
                    });
                  }
                },
                child: Text(
                  selectedDateRange == null
                      ? 'Selecionar Período'
                      : 'Período: ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}',
                  style: TextStyle(fontSize: 16, color: corPadrao()),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  title: Text(
                      'Não selecionar filtros irá gerar um relatório geral.'),
                  leading: Icon(Icons.warning_amber_rounded),
                ),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: corPadrao(),
                minimumSize: const Size(20, 42),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              child: const Text(
                "Gerar",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              onPressed: () async {
                if (cliid != '' && selectedDateRange != null) {
                  await generateAndPrintPdfClienteDataRange(
                      context,
                      cliid.toString(),
                      selectedDateRange!,
                      email,
                      tipoUser,
                      emailFiliado,
                      idFiliado,
                      idUser,
                      size);
                } else if (cliid != '') {
                  await generateAndPrintPdfCliente(context, cliid.toString(),
                      email, tipoUser, emailFiliado, idFiliado, idUser, size);
                } else if (selectedDateRange != null) {
                  await generateAndPrintPdfDateRange(
                      context,
                      selectedDateRange!,
                      email,
                      tipoUser,
                      emailFiliado,
                      idFiliado,
                      idUser,
                      size);
                } else {
                  await generateAndPrintPdf(context, email, tipoUser,
                      emailFiliado, idFiliado, idUser, size);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
    },
  );
}

Future<List<String>> _setListCliente(String email, String tipoUser,
    String idUser, String? emailFiliado, String? idFiliado) async {
  List<String> listClienteDrop = [];

  var query = tipoUser == 'master'
      ? (emailFiliado == null
          ? await FirebaseFirestore.instance.collection('clientes').get()
          : await FirebaseFirestore.instance
              .collection('clientes')
              .where('id_user', isEqualTo: idFiliado)
              .get())
      : await FirebaseFirestore.instance
          .collection('clientes')
          .where('id_user', isEqualTo: idUser)
          .get();

  for (var doc in query.docs) {
    listClienteDrop.add(
        '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['phone_number']}');
  }

  return listClienteDrop;
}

Future<String?> fetchAndSetIdCliente(
    String? cliSelecionado,
    String email,
    String tipoUser,
    String? emailFiliado,
    String? idFiliado,
    String idUser) async {
  var query = tipoUser == 'master'
      ? (emailFiliado == null
          ? await FirebaseFirestore.instance.collection('clientes').get()
          : await FirebaseFirestore.instance
              .collection('clientes')
              .where('id_user', isEqualTo: idFiliado)
              .get())
      : await FirebaseFirestore.instance
          .collection('clientes')
          .where('id_user', isEqualTo: idUser)
          .get();

  for (var doc in query.docs) {
    if (cliSelecionado ==
        '${doc['name']} | Email: ${doc['email']} | Whatsapp: ${doc['phone_number']}') {
      return doc['name'];
    }
  }
  return null;
}

Future<void> generateAndPrintPdfClienteDataRange(
    BuildContext context,
    String nomeCliente,
    DateTimeRange selectedDateRange,
    String email,
    String tipoUser,
    String? emailFiliado,
    String? idFiliado,
    String idUser,
    Size size) async {
  List<Map<String, dynamic>> listVendas = [];
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  final pdf = pw.Document();

  final vendas = FirebaseFirestore.instance
      .collection('vendas')
      .where('id_user', isEqualTo: idFiliado ?? idUser)
      .where('name', isEqualTo: nomeCliente)
      .where('first_execution',
          isGreaterThanOrEqualTo:
              DateFormat('dd/MM/yyyy').format(selectedDateRange.start))
      .where('first_execution',
          isLessThanOrEqualTo:
              DateFormat('dd/MM/yyyy').format(selectedDateRange.end));

  final queryVendas = await vendas.get();

  final produtos = FirebaseFirestore.instance
      .collection('products')
      .where('email_user', isEqualTo: emailFiliado ?? email);

  final queryProdutos = await produtos.get();

  for (var doc in queryVendas.docs) {
    Map<String, dynamic> data = doc.data();

    for (var produto in queryProdutos.docs) {
      if (doc['plan']['id'] == produto['plan_id']) {
        data['produto'] = produto['name'];
        break;
      }
    }

    listVendas.add(data);
  }

  pdf.addPage(pw.Page(build: (pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Relatório de Vendas',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text('Cliente: $nomeCliente'),
        pw.Text(
            'Período: ${DateFormat('dd/MM/yyyy').format(selectedDateRange.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange.end)}'),
        pw.Divider(),
        pw.Table.fromTextArray(
          headers: ['Produto', 'Valor', 'Data', 'Forma Pagamento', 'Status'],
          data: listVendas
              .map((item) => [
                    item['produto'],
                    formatWithComma(item['total']),
                    item['first_execution'],
                    item['payment'],
                    item['status']
                  ])
              .toList(),
        ),
        pw.Divider(),
        pw.Text('Data de geração: ${formatoData.format(datahora)}')
      ],
    );
  }));

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

Future<void> generateAndPrintPdfDateRange(
    BuildContext context,
    DateTimeRange selectedDateRange,
    String email,
    String tipoUser,
    String? emailFiliado,
    String? idFiliado,
    String idUser,
    Size size) async {
  List<Map<String, dynamic>> listVendas = [];
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  final pdf = pw.Document();

  final vendas = FirebaseFirestore.instance
      .collection('vendas')
      .where('id_user', isEqualTo: idFiliado ?? idUser)
      .where('first_execution',
          isGreaterThanOrEqualTo:
              DateFormat('dd/MM/yyyy').format(selectedDateRange.start))
      .where('first_execution',
          isLessThanOrEqualTo:
              DateFormat('dd/MM/yyyy').format(selectedDateRange.end));

  final queryVendas = await vendas.get();

  final produtos = FirebaseFirestore.instance
      .collection('products')
      .where('email_user', isEqualTo: emailFiliado ?? email);

  final queryProdutos = await produtos.get();

  for (var doc in queryVendas.docs) {
    Map<String, dynamic> data = doc.data();

    for (var produto in queryProdutos.docs) {
      if (doc['plan']['id'] == produto['plan_id']) {
        data['produto'] = produto['name'];
        break;
      }
    }

    listVendas.add(data);
  }

  pdf.addPage(pw.Page(build: (pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Relatório de Vendas',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            'Período: ${DateFormat('dd/MM/yyyy').format(selectedDateRange.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange.end)}'),
        pw.Divider(),
        pw.Table.fromTextArray(
          headers: [
            'Cliente',
            'Produto',
            'Valor',
            'Data',
            'Forma Pagamento',
            'Status'
          ],
          data: listVendas
              .map((item) => [
                    item['name'],
                    item['produto'],
                    formatWithComma(item['total']),
                    item['first_execution'],
                    item['payment'],
                    item['status']
                  ])
              .toList(),
        ),
        pw.Divider(),
        pw.Text('Data de geração: ${formatoData.format(datahora)}')
      ],
    );
  }));

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

Future<void> generateAndPrintPdfCliente(
    BuildContext context,
    String nomeCliente,
    String email,
    String tipoUser,
    String? emailFiliado,
    idFiliado,
    idUser,
    Size size) async {
  List<Map<String, dynamic>> listVendas = [];
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  final pdf = pw.Document();

  final vendas = FirebaseFirestore.instance
      .collection('vendas')
      .where('id_user', isEqualTo: idFiliado ?? idUser)
      .where('name', isEqualTo: nomeCliente);

  final queryVendas = await vendas.get();

  final produtos = FirebaseFirestore.instance
      .collection('products')
      .where('email_user', isEqualTo: emailFiliado ?? email);

  final queryProdutos = await produtos.get();

  for (var doc in queryVendas.docs) {
    Map<String, dynamic> data = doc.data();

    for (var produto in queryProdutos.docs) {
      if (doc['plan']['id'] == produto['plan_id']) {
        data['produto'] = produto['name'];
        break;
      }
    }

    listVendas.add(data);
  }

  pdf.addPage(pw.Page(build: (pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Relatório de Vendas',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text('Cliente: $nomeCliente'),
        pw.Divider(),
        pw.Table.fromTextArray(
          headers: ['Produto', 'Valor', 'Data', 'Forma Pagamento', 'Status'],
          data: listVendas
              .map((item) => [
                    item['produto'],
                    formatWithComma(item['total']),
                    item['first_execution'],
                    item['payment'],
                    item['status']
                  ])
              .toList(),
        ),
        pw.Text('Data de geração: ${formatoData.format(datahora)}')
      ],
    );
  }));

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

Future<void> generateAndPrintPdf(
    BuildContext context,
    String email,
    String tipoUser,
    String? emailFiliado,
    String? idFiliado,
    String idUser,
    Size size) async {
  List<Map<String, dynamic>> listVendas = [];
  DateTime datahora = DateTime.now();
  DateFormat formatoData = DateFormat('dd/MM/yyyy | HH:mm');

  final pdf = pw.Document();

  final vendas = FirebaseFirestore.instance
      .collection('vendas')
      .where('id_user', isEqualTo: idFiliado ?? idUser);

  final queryVendas = await vendas.get();

  final produtos = FirebaseFirestore.instance
      .collection('products')
      .where('email_user', isEqualTo: emailFiliado ?? email);

  final queryProdutos = await produtos.get();

  for (var doc in queryVendas.docs) {
    Map<String, dynamic> data = doc.data();

    for (var produto in queryProdutos.docs) {
      if (doc['plan']['id'] == produto['plan_id']) {
        data['produto'] = produto['name'];
        break;
      }
    }

    listVendas.add(data);
  }

  pdf.addPage(pw.Page(build: (pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Relatório de Vendas',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        pw.Table.fromTextArray(
          headers: [
            'Cliente',
            'Produto',
            'Valor',
            'Data',
            'Forma Pagamento',
            'Status'
          ],
          data: listVendas
              .map((item) => [
                    item['name'],
                    item['produto'],
                    formatWithComma(item['total']),
                    item['first_execution'],
                    item['payment'],
                    item['status']
                  ])
              .toList(),
        ),
        pw.Divider(),
        pw.Text('Data de geração: ${formatoData.format(datahora)}')
      ],
    );
  }));

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
