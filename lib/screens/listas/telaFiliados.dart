import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:smart_pagamento/inutilizados/telaCadastroCliente.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
import 'package:smart_pagamento/screens/widgets/showdialog.dart';

class FiliadosScreen extends StatefulWidget {
  final String? email;
  final String tipoUser;
  final String idUser;

  const FiliadosScreen(
      {Key? key, this.email, required this.tipoUser, required this.idUser})
      : super(key: key);

  @override
  _FiliadosScreenState createState() => _FiliadosScreenState();
}

class _FiliadosScreenState extends State<FiliadosScreen> {
  String searchQuery = "";
  //List _listProdutosEscolhidos = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Meus Filiados',
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
        padding: size.width <= 720
            ? const EdgeInsets.only(top: 40, left: 10, right: 10)
            : const EdgeInsets.only(top: 40, left: 50, right: 50),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                labelText: 'Pesquisar Filiado',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  borderSide: BorderSide(
                    color: corPadrao(),
                    width: 3.0,
                  ),
                ),
              ),
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
                    .collection('users')
                    .where('tipo_user', isEqualTo: 'filiado')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filiados = snapshot.data!.docs.where((cliente) {
                    return cliente['name']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);
                  }).toList();

                  if (filiados.isEmpty) {
                    return const Center(
                        child: Text('Nenhum filiado encontrado',
                            style: TextStyle(color: Colors.white)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filiados.length,
                    itemBuilder: (context, index) {
                      final filiado = filiados[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(
                            filiado['name'],
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Email: ${filiado['email']} \nWhatsApp: ${filiado['whatsapp']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                  icon: Icon(
                                      filiado['is_valid']
                                          ? Icons.check
                                          : Icons.do_not_disturb,
                                      color: Colors.white),
                                  tooltip: 'Desativar',
                                  onPressed: () async {
                                    final TextEditingController
                                        passwordController =
                                        TextEditingController();

                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(filiado['is_valid']
                                            ? 'Deseja desativar o filiado?'
                                            : 'Deseja ativar o filiado?'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(filiado['is_valid']
                                                ? 'O acesso do filiado a plataforma será negado.'
                                                : 'O acesso do filiado a plataforma será liberado.'),
                                            const SizedBox(height: 10),
                                            TextFormField(
                                              controller: passwordController,
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                labelText: 'Senha',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancelar',
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade400)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final password =
                                                  passwordController.text;
                                              bool isAuthenticated =
                                                  await _reauthenticateUser(
                                                      password);

                                              if (isAuthenticated) {
                                                //_deleteFiliado(filiado.id,  filiado['email']);
                                                filiado['is_valid']
                                                    ? _desativaFiliado(
                                                        filiado.id)
                                                    : _ativaFiliado(filiado.id);
                                                Navigator.pop(
                                                    context); // Fecha o dialog de senha
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                   SnackBar(
                                                      content: Text(filiado[
                                                              'is_valid']
                                                          ? 'Filiado desativado com sucesso!'
                                                          : 'Filiado ativado com sucesso!')),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Senha incorreta. Tente novamente.')),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: corPadrao(),
                                            ),
                                            child: const Text('Excluir',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
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
  /*

  void _deleteFiliado(String filiadoId, String emailFiliado) async {
    final clientesSnapshot = await FirebaseFirestore.instance
        .collection('clientes')
        .where('id_user', isEqualTo: filiadoId)
        .get();

    final produtosSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: filiadoId)
        .get();

    bool cancelamentoComSucesso = true;

    for (var cliente in clientesSnapshot.docs) {
      final assinaturasSnapshot = await FirebaseFirestore.instance
          .collection('clientes')
          .doc(cliente.id)
          .collection('assinaturas')
          .get();

      for (var doc in assinaturasSnapshot.docs) {
        final response =
            await ApiService().cancelarAssinatura(int.parse(doc.id));

        if (response['status'] == 200) {
          await doc.reference.update({'status': 'cancelado'});
        } else {
          cancelamentoComSucesso = false;
          break;
        }
      }

      if (cancelamentoComSucesso) {
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(cliente.id)
            .delete();
      }
    }

    for (var produto in produtosSnapshot.docs) {
      ApiService apiService = ApiService();

      var responseDelete = await apiService.deletarPlano(produto['plan_id']);

      if (responseDelete['status'] == 200) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(produto.id)
            .delete();
      } else {
        cancelamentoComSucesso = false;
        break;
      }
    }

    if (cancelamentoComSucesso) {
      //await FirebaseAuth.instance.currentUser!.delete();
      //deletar usuario especifico

      await FirebaseFirestore.instance
          .collection('users')
          .doc(filiadoId)
          .update({'is_valid': false});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Filiado, clientes, produtos e assinaturas relacionadas foram canceladas com sucesso!')),
      );
      setState(() {});
    } else {
      showDialogApi(context);
    }
  }
  */
  
  void _desativaFiliado(String filiadoId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(filiadoId)
        .update({'is_valid': false});
  }

  void _ativaFiliado(String filiadoId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(filiadoId)
        .update({'is_valid': true});
  }

  Future<bool> _reauthenticateUser(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final authCredential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(authCredential);
      return true;
    } catch (e) {
      print('Erro na reautenticação: $e');
      return false;
    }
  }

/*
  Future<List<Map<String, dynamic>>> _getAssinaturas(String clienteId) async {
    final assinaturasSnapshot = await FirebaseFirestore.instance
        .collection('clientes')
        .doc(clienteId)
        .collection('assinaturas')
        .get();

    final products = await FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: widget.email!)
        .get();

    return assinaturasSnapshot.docs.map((doc) {
      String name = '';

      for (var product in products.docs) {
        if (product['plan_id'] == doc['plan']['id']) {
          name = product['name'];
          break;
        }
      }

      return {
        'id': doc.id,
        'name': name,
        'chargeId': doc['charge']['id'].toString(),
        'status': doc['status'],
      };
    }).toList();
  }


  void _showProducts(BuildContext context,
      List<Map<String, dynamic>> assinaturas, String clienteId) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assinaturas'),
        content: Container(
          width: double.maxFinite,
          child: assinaturas.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: assinaturas.length,
                  itemBuilder: (context, index) {
                    final assinatura = assinaturas[index];
                    return Card(
                      child: ListTile(
                        title: Text(assinatura['name']),
                        subtitle: Text('Status: ${assinatura['status']}'),
                        trailing: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.red, Colors.redAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.cancel_outlined,
                                color: Colors.white),
                            tooltip: 'Cancelar Assinatura',
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                      'Deseja cancelar essa assinatura?'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Digite sua senha para confirmar o cancelamento:',
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: passwordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Senha',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancelar',
                                          style: TextStyle(
                                              color: Colors.grey.shade400)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final password =
                                            passwordController.text;
                                        bool isAuthenticated =
                                            await _reauthenticateUser(password);

                                        if (isAuthenticated) {
                                          await _cancelarAssinatura(
                                              assinatura['id'],
                                              context,
                                              clienteId);
                                          Navigator.pop(
                                              context); // Fecha o dialog de senha
                                          Navigator.pop(
                                              context); // Fecha o dialog de assinaturas
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Senha incorreta. Tente novamente.')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: corPadrao()),
                                      child: const Text('Confirmar',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Text(
                  'Nenhuma assinatura encontrada.',
                  style: TextStyle(color: Colors.white70),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

 

  Future<void> _cancelarAssinatura(
      String assinaturaId, BuildContext context, String clienteId) async {
    final response =
        await ApiService().cancelarAssinatura(int.parse(assinaturaId));

    if (response['status'] == 200) {
      await FirebaseFirestore.instance
          .collection('recebimentos')
          .doc(assinaturaId)
          .update({'status': 'cancelado'});

      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(clienteId)
          .collection('assinaturas')
          .doc(assinaturaId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assinatura cancelada com sucesso!')),
      );

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cancelar assinatura.')),
      );
    }
  }
*/
}

/*

*/