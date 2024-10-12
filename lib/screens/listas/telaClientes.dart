import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_pagamento/screens/cadastros/telaCadastroCliente.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
//import 'package:smart_pagamento/screens/widgets/textfield.dart';

class ClienteListScreen extends StatefulWidget {
  final String? email;
  final String tipoUser;

  const ClienteListScreen({Key? key, this.email, required this.tipoUser}) : super(key: key);

  @override
  _ClienteListScreenState createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen> {
  String searchQuery = "";
  List _listProdutosEscolhidos = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
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
        backgroundColor: corPadrao(),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                labelText: 'Pesquisar Cliente',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // Cor da borda
                    width: 2.0, // Espessura da borda
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // Cor da borda
                    width: 2.0, // Espessura da borda
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color:
                        corPadrao(), // Cor da borda quando o campo está focado
                    width: 3.0, // Espessura da borda quando o campo está focado
                  ),
                ),
              ),
              //style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: widget.tipoUser == 'master' 
                ? FirebaseFirestore.instance
                    .collection('clientes')
                    //.where('email_user', isEqualTo: widget.email)
                    .snapshots() 
                  : FirebaseFirestore.instance
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
                        //color: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(
                            cliente['name'],
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Email: ${cliente['email']} \nWhatsApp: ${cliente['whatsapp']}',
                            // style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
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
                                icon: const Icon(
                                  Icons.delete,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      //backgroundColor: Colors.black87,
                                      title: const Text(
                                        'Deseja excluir o cliente?',
                                        //style:TextStyle(color: Colors.white)
                                      ),

                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Cancelar',
                                              style: TextStyle(
                                                  color: Colors.grey.shade400)),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: gradientBtn(),
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ElevatedButton(
                                              onPressed: () {
                                                _deleteCliente(cliente.id);
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  fixedSize: Size(
                                                      size.width * 0.1,
                                                      size.height * 0.01),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                              child: Text('Excluir',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          size.height * 0.022,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ],
                                    ),
                                  );
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
                                    await _getDataItensVendas(cliente.id);
                                    _showProducts(context);
                                  },
                                ),
                              )
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

    var iven = await FirebaseFirestore.instance
        .collection('itens_vendas')
        .where('email_user', isEqualTo: widget.email)
        .get();
    
    
    var vendas = await FirebaseFirestore.instance
        .collection('vendas')
        .where('email_user', isEqualTo: widget.email)
        .get();

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
