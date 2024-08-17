import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:smart_pagamento/screens/cadastros/telaCadastroCliente.dart';

class ClienteListScreen extends StatefulWidget {
  final String? email;

  const ClienteListScreen({Key? key, this.email}) : super(key: key);

  @override
  _ClienteListScreenState createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen> {
  String searchQuery = "";
  List _listProdutosEscolhidos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Meus Clientes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 38,
          ),
        ),
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
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquisar Cliente',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('clientes')
                    .where('email_user', isEqualTo: widget.email)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final clientes = snapshot.data!.docs.where((cliente) {
                    return cliente['name']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);
                  }).toList();

                  if (clientes.isEmpty) {
                    return const Center(
                        child: Text('Nenhum cliente encontrado',
                            style: TextStyle(color: Colors.white)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];

                      return Card(
                        color: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(
                            cliente['name'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Email: ${cliente['email']} - WhatsApp: ${cliente['whatsapp']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RegistraCliente(
                                          clienteId: cliente.id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.black87,
                                      title: const Text(
                                          'Deseja excluir o cliente?',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancelar',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deleteCliente(cliente.id);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Excluir',
                                              style: TextStyle(
                                                  color: Colors.redAccent)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.list, color: Colors.white),
                                tooltip: 'Itens Vendas',
                                onPressed: () async {
                                  await _getDataItensVendas(cliente.id);
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
          ],
        ),
      ),
    );
  }

  void _deleteCliente(String clienteId) {
    FirebaseFirestore.instance.collection('clientes').doc(clienteId).delete();
  }

  Future<void> _getDataItensVendas(String clienteid) async {
    _listProdutosEscolhidos.clear();

    var iven =
        await FirebaseFirestore.instance.collection('itens_vendas').where('email_user', isEqualTo: widget.email).get();
    var vendas = await FirebaseFirestore.instance.collection('vendas').where('email_user', isEqualTo: widget.email).get();

    for (var docven in vendas.docs) {
      if (clienteid == docven['idcliente']) {
        for (var doc in iven.docs) {
          if (docven.id == doc['idvenda']) {
            _listProdutosEscolhidos.add(doc['produto']);
          }
        }
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
