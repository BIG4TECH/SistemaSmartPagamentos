import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/screens/cadastros/telaCadastroVenda.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';

class VendasListScreen extends StatefulWidget {
  final String? email;
  final String tipoUser;
  const VendasListScreen({required this.email, required this.tipoUser});

  @override
  _VendasListScreenState createState() => _VendasListScreenState();
}

class _VendasListScreenState extends State<VendasListScreen> {
  List _listProdutosEscolhidos = [];
  List _listValorBrutoProd = [];
  List _listValorDescontadoProd = [];
  List _listValorLiqProd = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Minhas Vendas',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            )),
        centerTitle: true,
        backgroundColor: corPadrao(),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 40, left: 50, right: 50),
        child: StreamBuilder(
          stream: widget.tipoUser == 'master'
              ? FirebaseFirestore.instance
                  .collection('vendas')
                  .orderBy('data', descending: true)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('vendas')
                  .where('email_user', isEqualTo: widget.email)
                  .orderBy('data', descending: true)
                  .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final vendas = snapshot.data!.docs;

            if (size.width > 720) {
              // Exibição em forma de tabela para telas maiores
              return Center(
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: size.width * 0.1,
                    columns: [
                      DataColumn(
                          label: Text('Total Bruto',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.height * 0.03))),
                      DataColumn(
                          label: Text('Total Liq.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.height * 0.03))),
                      DataColumn(
                          label: Text('Data',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.height * 0.03))),
                      DataColumn(
                          label: Text('Ações',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.height * 0.03))),
                    ],
                    rows: vendas
                        .map(
                          (venda) => DataRow(
                            cells: [
                              DataCell(Text(
                                  'R\$${venda['total_bruto'].toString()}',
                                  style: TextStyle(
                                      fontSize: size.height * 0.025))),
                              DataCell(Text(
                                  'R\$${venda['total_liq'].toString()}',
                                  style: TextStyle(
                                      fontSize: size.height * 0.025))),
                              DataCell(
                                Text(venda['data_hora'],
                                    style: TextStyle(
                                        fontSize: size.height * 0.025)),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => RegistraVenda(
                                                vendaId: venda.id),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                      ),
                                      onPressed: () {
                                        _confirmDeleteVenda(context, venda.id);
                                      },
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradientBtn(),
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.list,
                                            color: Colors.white),
                                        tooltip: 'Itens Vendas',
                                        onPressed: () async {
                                          await _getDataItensVendas(venda.id);
                                          _showProducts(context);
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            } else {
              // Exibição em forma de lista ou cards para telas menores
              return ListView.builder(
                itemCount: vendas.length,
                itemBuilder: (context, index) {
                  final venda = vendas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    //elevation: 4,
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Bruto: \nR\$${venda['total_bruto'].toString()}',
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'Total Líquido: \nR\$${venda['total_liq'].toString()}',
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'Data: \n${venda['data_hora']}',
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.list, color: Colors.blue),
                            onPressed: () async {
                              await _getDataItensVendas(venda.id);
                              _showProducts(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteVenda(String vendaId) async {
    var query = await FirebaseFirestore.instance
        .collection('itens_vendas')
        .where('idvenda', isEqualTo: vendaId)
        .get();

    for (var doc in query.docs) {
      await FirebaseFirestore.instance
          .collection('itens_vendas')
          .doc(doc.id)
          .delete();
    }

    await FirebaseFirestore.instance.collection('vendas').doc(vendaId).delete();
  }

  Future<void> _getDataItensVendas(String vendaId) async {
    _listProdutosEscolhidos.clear();
    _listValorBrutoProd.clear();
    _listValorDescontadoProd.clear();
    _listValorLiqProd.clear();

    var query = widget.tipoUser == 'master'
        ? await FirebaseFirestore.instance.collection('itens_vendas').get()
        : await FirebaseFirestore.instance
            .collection('itens_vendas')
            .where('email_user', isEqualTo: widget.email)
            .get();

    for (var doc in query.docs) {
      if (vendaId == doc['idvenda']) {
        _listProdutosEscolhidos.add(doc['produto']);
        _listValorBrutoProd.add(doc['total_bruto_prod']);
        _listValorDescontadoProd.add(doc['valor_descontado']);
        _listValorLiqProd.add(doc['total_liq_prod']);
      }
    }
  }

  void _showProducts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Produtos Escolhidos',
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          width: double.maxFinite,
          child: _listProdutosEscolhidos.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: _listProdutosEscolhidos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _listProdutosEscolhidos[index],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                )
              : const Text(
                  'Nenhum produto escolhido.',
                  style: TextStyle(color: Colors.white70),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVenda(BuildContext context, String vendaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Deseja excluir o produto?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientBtn(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                _deleteVenda(vendaId);
                Navigator.pop(context);
              },
              child: const Text('Excluir',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
