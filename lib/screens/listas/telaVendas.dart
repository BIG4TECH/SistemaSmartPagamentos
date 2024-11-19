import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:smart_pagamento/inutilizados/telaCadastroVenda.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
import 'package:smart_pagamento/screens/widgets/editarNumero.dart';

class VendasListScreen extends StatefulWidget {
  final String? email;
  final String tipoUser;
  final String idUser;

  const VendasListScreen(
      {required this.email, required this.tipoUser, required this.idUser});

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
        title: const Text('Histórico de Vendas',
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
          stream: FirebaseFirestore.instance
              .collection('vendas')
              .where('id_user', isEqualTo: widget.idUser)
              .orderBy('first_execution', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              print(!snapshot.hasData);
              return Center(child: Text('Não há vendas realizadas!'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final vendas = snapshot.data!.docs;

            if (size.width > 720) {
              // Exibição em forma de tabela para telas maiores
              return Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: size.width * 0.1,
                    columns: [
                      DataColumn(
                          label: Text('Cliente',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.height * 0.03))),
                      DataColumn(
                          label: Text('Valor',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.height * 0.03))),
                      DataColumn(
                          label: Text('Data',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.height * 0.03))),
                      DataColumn(
                          label: Text('Status',
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
                              DataCell(Text('${venda['name']}',
                                  style: TextStyle(
                                      fontSize: size.height * 0.025))),
                              DataCell(Text(
                                  'R\$${formatWithComma(venda['total'])}',
                                  style: TextStyle(
                                      fontSize: size.height * 0.025))),
                              DataCell(
                                Text(venda['first_execution'],
                                    style: TextStyle(
                                        fontSize: size.height * 0.025)),
                              ),
                              DataCell(
                                Text(
                                    venda['status'] == 'active'
                                        ? 'Recebido'
                                        : venda['status'] == 'waiting'
                                            ? 'Pendente'
                                            : 'Cancelado',
                                    style: TextStyle(
                                        fontSize: size.height * 0.025)),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    /*
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
                                    */
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
                                        tooltip: 'Item',
                                        onPressed: () async {
                                          await _getDataVenda(venda.id);
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
                            'Cliente: ${venda['name'].toString()}',
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'Total: ${venda['total'].toString()}',
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'Data: ${venda['first_execution']}',
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'Status: ${venda['status'] == 'active' ? 'Ativo' : venda['status'] == 'waiting' ? 'Aguardando' : 'Cancelado'}',
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
                              await _getDataVenda(venda.id);
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

  /*
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
  */

  Future<void> _getDataVenda(String vendaId) async {
    _listProdutosEscolhidos.clear();
    _listValorBrutoProd.clear();
    _listValorDescontadoProd.clear();
    _listValorLiqProd.clear();

    var query = await FirebaseFirestore.instance
        .collection('vendas')
        .doc(vendaId)
        .get();

    var produto = await FirebaseFirestore.instance
        .collection('products')
        .where('plan_id', isEqualTo: query['plan']['id'])
        .get();

    _listProdutosEscolhidos.add(produto.docs.first['name']);
    _listValorBrutoProd.add(formatWithComma(query['total']));
    //_listValorDescontadoProd.add(doc['valor_descontado']);
    //_listValorLiqProd.add(doc['total_liq_prod']);
  }

  void _showProducts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //backgroundColor: Colors.black,
        title: const Text(
          'Produto Escolhido',
          //style: TextStyle(color: Colors.white),
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
                        //style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                )
              : const Text(
                  'Nenhum produto escolhido.',
                  //style: TextStyle(color: Colors.white70),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              //style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /*
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
  */
}
