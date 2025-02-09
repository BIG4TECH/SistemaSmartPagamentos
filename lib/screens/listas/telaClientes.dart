import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_pagamento/routes/api_service.dart';
import 'package:smart_pagamento/widgets/cores.dart';
import 'package:smart_pagamento/widgets/editarNumero.dart';
import 'package:smart_pagamento/widgets/showdialog.dart';

class ClienteListScreen extends StatefulWidget {
  final String? email;
  final String tipoUser;
  final String idUser;

  const ClienteListScreen(
      {Key? key, this.email, required this.tipoUser, required this.idUser})
      : super(key: key);

  @override
  _ClienteListScreenState createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen> {
  String searchQuery = "";
  List<dynamic> cliMensagens = [];

  void mensagensPendentes() async {
    var response = await ApiService().getMensagensPendentes(widget.idUser);

    if (!response.containsKey('error')) {
      setState(() {
        cliMensagens = response['body'] as List<dynamic>;
      });
    }
  }

  initState() {
    super.initState();
    mensagensPendentes();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Meus Clientes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size.width <= 720 ? 24 : 38,
          ),
        ),
        centerTitle: true,
        backgroundColor: corPadrao(),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.solidPaperPlane, size: 18),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Atenção!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                        'Deseja reenviar todas as mensagens de cobrança pendentes?\nMensagens pendentes: ${cliMensagens.length}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: corPadrao(),
                        ),
                        onPressed: () async {
                          try {
                            var response = await ApiService()
                                .getMensagensPendentes(widget.idUser);

                            if (response.containsKey('error')) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Atenção!'),
                                    content:
                                        Text('Não há mensagens pendentes.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Fechar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              final mensagens =
                                  response['body'] as List<dynamic>;

                              print('mensagens + $mensagens');

                              if (mensagens.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Atenção!'),
                                      content:
                                          Text('Não há mensagens pendentes.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Fechar'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor:
                                        Color.fromARGB(255, 248, 203, 0),
                                    content: Text(
                                      'Enviando mensagens... Permaneça na tela até a conclusão.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )),
                              );

                              for (var mensagem in mensagens) {
                                await ApiService().enviarMensagem(
                                  widget.idUser,
                                  mensagem['cliente'],
                                  mensagem['message'],
                                );
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      'Mensagens reenviadas com sucesso!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )),
                              );
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            print(e);
                            Navigator.pop(context);
                            showDialogApi(context);
                          }
                        },
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: Container(
        padding: size.width <= 720
            ? const EdgeInsets.only(top: 20, left: 10, right: 10)
            : const EdgeInsets.only(top: 40, left: 50, right: 50),
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
                    .collection('clientes')
                    .where('id_user', isEqualTo: widget.idUser)
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
                        child: Text(
                      'Nenhum cliente encontrado',
                    ));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];
                      bool temMensagemPendente = false;

                      for (var mensagem in cliMensagens) {
                        if (mensagem['cliente'] == cliente['phone_number']) {
                          temMensagemPendente = true;
                          break;
                        }
                      }

                      return Card(
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
                            'Email: ${cliente['email']} \nWhatsApp: ${cliente['phone_number']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /*
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RegistraCliente(
                                        clienteId: cliente.id,
                                        idUser: cliente['id_user'],
                                      ),
                                    ),
                                  );
                                },
                              ),*/
                              /*
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  final TextEditingController
                                      passwordController =
                                      TextEditingController();

                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Deseja excluir o cliente?'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                              'Todos as assinaturas serão canceladas.'),
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
                                                  color: Colors.grey.shade400)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            final password =
                                                passwordController.text;
                                            bool isAuthenticated =
                                                await _reauthenticateUser(
                                                    password);

                                            if (isAuthenticated) {
                                              //_deleteCliente(cliente.id);
                                              Navigator.pop(
                                                  context); // Fecha o dialog de senha
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Cliente excluído com sucesso!')),
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
                              */
                              temMensagemPendente
                                  ? IconButton(
                                      icon: FaIcon(
                                          FontAwesomeIcons.solidPaperPlane),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Atenção!',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: Text(
                                                  'Deseja reenviar a mensagem de cobrança?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        corPadrao(),
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      var response =
                                                          await ApiService()
                                                              .getMensagensPendentes(
                                                                  widget
                                                                      .idUser);

                                                      if (response.containsKey(
                                                          'error')) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Atenção!'),
                                                              content: Text(
                                                                  'Não há mensagens pendentes.'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      'Fechar'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        final mensagens =
                                                            response['body']
                                                                as List<
                                                                    dynamic>;

                                                        print(
                                                            'mensagens + $mensagens');

                                                        if (mensagens.isEmpty) {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    'Atenção!'),
                                                                content: Text(
                                                                    'Não há mensagens pendentes.'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                        'Fechar'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );

                                                          return;
                                                        }

                                                        for (var mensagem
                                                            in mensagens) {
                                                          if (mensagem[
                                                                  'cliente'] ==
                                                              cliente[
                                                                  'phone_number']) {
                                                            await ApiService()
                                                                .enviarMensagem(
                                                              widget.idUser,
                                                              mensagem[
                                                                  'cliente'],
                                                              mensagem[
                                                                  'message'],
                                                            );

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  content: Text(
                                                                    'Mensagens reenviadas com sucesso!',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white),
                                                                  )),
                                                            );
                                                          }
                                                        }

                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    } catch (e) {
                                                      print(e);
                                                      Navigator.pop(context);
                                                      showDialogApi(context);
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Confirmar',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    )
                                  : const SizedBox(),
                              SizedBox(width: 10),
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
                                    List<Map<String, dynamic>> assinaturaId =
                                        await _getAssinaturas(cliente['email']);
                                    _showProducts(context, assinaturaId,
                                        cliente['email']);
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
  void _deleteCliente(String clienteId) async {
    final assinaturasSnapshot = await FirebaseFirestore.instance
        .collection('clientes')
        .doc(clienteId)
        .collection('assinaturas')
        .get();

    bool cancelamentoComSucesso = true;

    for (var doc in assinaturasSnapshot.docs) {
      final response = await ApiService().cancelarAssinatura(int.parse(doc.id));

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
          .doc(clienteId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cliente e assinaturas canceladas com sucesso!')),
      );
      setState(() {});
    } else {
      showDialogApi(context);
    }
  }
  */
  Future<List<Map<String, dynamic>>> _getAssinaturas(
      String emailCliente) async {
    final assinaturasSnapshot = await FirebaseFirestore.instance
        .collection('vendas')
        .where('id_cliente', isEqualTo: emailCliente)
        .get();

    final products = await FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: widget.idUser)
        .get();

    List<Map<String, dynamic>> result = [];

    for (var assinatura in assinaturasSnapshot.docs) {
      String name = '';
      List? charges;

      for (var product in products.docs) {
        if (product.id == assinatura['plan']) {
          /*
          final snapshotCharges = await FirebaseFirestore.instance
              .collection('vendas')
              .doc(clienteId)
              .collection('assinaturas')
              .doc(assinatura.id)
              .collection('charge')
              .get();
          */
          final snapshotCharges = await FirebaseFirestore.instance
              .collection('vendas')
              .doc(assinatura.id)
              .collection('charge')
              .get();

          name = product['name'];

          charges =
              snapshotCharges.docs.map((charge) => charge.data()).toList();

          //print(charges);
          break;
        }
      }

      result.add({
        'id': assinatura.id,
        'name': name,
        'charges': charges,
        'status': assinatura['status'],
      });
    }
    //print(result);

    return result;
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
                    final charges =
                        assinatura['charges'] as List<Map<String, dynamic>>?;
                    //print(assinatura);
                    return Card(
                      child: ExpansionTile(
                        title: Text(assinatura['name'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Status: ${assinatura['status'] == 'active' ? 'Ativo' : 'Cancelado'}'),
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
                        children: [
                          if (charges != null && charges.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: charges.length,
                              itemBuilder: (context, chargeIndex) {
                                final charge = charges[chargeIndex];
                                return ListTile(
                                  title: Text(
                                    'Parcela: ${charge['parcel']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Status: '),
                                          Padding(
                                              padding: const EdgeInsets.all(1),
                                              child: Card(
                                                color: charge['status'] ==
                                                        'waiting'
                                                    ? Colors.amber[300]
                                                    : Colors.green[300],
                                                child: Text(
                                                  charge['status'] == 'waiting'
                                                      ? 'Aguardando Pagamento'
                                                      : 'Pago',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              ))
                                        ],
                                      ),
                                      Text(
                                          'Total: ${formatWithComma(charge['total'])}'),
                                    ],
                                  ),
                                );
                              },
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Nenhuma cobrança encontrada.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                        ],
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

  Future<void> _cancelarAssinatura(
      String assinaturaId, BuildContext context, String clienteId) async {
    final response =
        await ApiService().cancelarAssinatura(int.parse(assinaturaId));

    if (response['status'] == 200) {
      /*
      await FirebaseFirestore.instance
          .collection('recebimentos')
          .doc(assinaturaId)
          .update({'status': 'cancelado'});
      */
      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(clienteId)
          .collection('assinaturas')
          .doc(assinaturaId)
          .update({'status': 'cancelado'});

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
}
