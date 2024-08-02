import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:smart_pagamento/screens/cadastros/telaCadastroVenda.dart';

class VendasListScreen extends StatefulWidget{
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Minhas Vendas',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 40, left: 50, right: 50),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(89, 19, 165, 1.0),
              Color.fromRGBO(93, 21, 178, 1.0),
              Color.fromRGBO(123, 22, 161, 1.0),
              Color.fromRGBO(153, 27, 147, 1.0),
            ],
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('vendas').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final vendas = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: vendas.length,
              itemBuilder: (context, index) {
                final venda = vendas[index];

                return Card(
                  color: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text(
                      'Cliente: ${venda['cliente']}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Total Liq.: R\$${venda['total_liq']} - Data: ${venda['data_hora']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RegistraVenda(vendaId: venda.id),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.black87,
                                title: const Text('Deseja excluir o produto?',
                                    style: TextStyle(color: Colors.white)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteVenda(venda.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Excluir',
                                        style:
                                            TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.list, color: Colors.white),
                          tooltip: 'Itens Vendas',
                          onPressed: () async{
                            
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
          },
        ),
      ),
    );
  }

  Future<void> _deleteVenda(String vendaId) async {
    var query = await FirebaseFirestore.instance.collection('itens_vendas').where('idvenda', isEqualTo: vendaId).get();

    
    for (var doc in query.docs) {
      await FirebaseFirestore.instance.collection('itens_vendas').doc(doc.id).delete();
    }

    await FirebaseFirestore.instance.collection('vendas').doc(vendaId).delete();
  }

  Future<void> _getDataItensVendas(String vendaId) async {
    _listProdutosEscolhidos.clear();
    _listValorBrutoProd.clear();
    _listValorDescontadoProd.clear();
    _listValorLiqProd.clear();

    var query = await FirebaseFirestore.instance.collection('itens_vendas').get();
       
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

}
