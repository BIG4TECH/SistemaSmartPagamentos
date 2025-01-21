import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:smart_pagamento/widgets/cores.dart';
import 'package:smart_pagamento/widgets/textfield.dart';

class RegistraCliente extends StatefulWidget {
  final String? clienteId;
  final String? email;
  final String idUser;

  RegistraCliente({super.key, this.clienteId, this.email, required this.idUser});

  @override
  _RegistraClienteState createState() => _RegistraClienteState();
}

class _RegistraClienteState extends State<RegistraCliente> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _wppController = MaskedTextController(mask: '(00) 00000-0000');
  final _cpfController = MaskedTextController(mask: '000.000.000-00');

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.clienteId != null) {
      _loadCliente();
    }
  }

  void _loadCliente() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('clientes')
        .where('id_user', isEqualTo: widget.idUser)
        .get();

    // Verificar se há documentos retornados pela consulta
    if (querySnapshot.docs.isNotEmpty) {
      // Percorre todos os documentos retornados pela consulta
      for (var doc in querySnapshot.docs) {
        if (doc.id == widget.clienteId) {
          var clienteData = doc.data() as Map<String, dynamic>;

          _nameController.text = clienteData['name'];
          _emailController.text = clienteData['email'];
          _wppController.text = clienteData['whatsapp'];
          _cpfController.text = clienteData['cpf'];
          break;
        }
      }
    } else {
      // Tratar o caso onde nenhum documento foi encontrado
      print('Nenhum produto encontrado para este usuário.');
    }
  }

  void _registerOrEditCliente() async {
    if (_formKey.currentState!.validate()) {
      if (widget.clienteId == null) {
        await FirebaseFirestore.instance.collection('clientes').add({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone_number': _wppController.text.replaceAll(RegExp(r'\D'), ''),
          'data_registro': DateTime.now(),
          'id_user': widget.idUser,
          'cpf': _cpfController.text
        });
      } else {
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone_number': _wppController.text.replaceAll(RegExp(r'\D'), ''),
          'id_user': widget.idUser,
          'cpf': _cpfController.text.replaceAll(RegExp(r'\D'), '')
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Cliente ${widget.clienteId == null ? 'registrado' : 'atualizado'} com sucesso!')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.clienteId == null
                  ? 'Cadastrar Clientes'
                  : 'Editar Clientes',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 38,
              )),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: corPadrao(),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Wrap(children: [
                Center(
                  child: Container(
                    margin: size.width <= 720
                        ? EdgeInsets.only(
                            left: size.width * 0.07, right: size.width * 0.07)
                        : const EdgeInsets.only(left: 150, right: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // NOME DO CLIENTE
                                TextFormField(
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                  controller: _nameController,
                                  decoration: inputDec('Nome do Cliente'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite o nome do cliente!';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                size.width <= 720
                                    ? Column(
                                        children: [
                                          // EMAIL
                                          TextFormField(
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold),
                                            controller: _emailController,
                                            decoration: inputDec('Email'),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Por favor, digite o email!';
                                              }
                                              return null;
                                            },
                                          ),

                                          const SizedBox(
                                            height: 20,
                                          ),

                                          //WHATSAPP
                                          TextFormField(
                                            //maxLength: 14,
                                            //maxLengthEnforcement: MaxLengthEnforcement.enforced,

                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold),
                                            controller: _wppController,
                                            decoration: inputDec('Whatsapp'),
                                            keyboardType: TextInputType.phone,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Por favor, digite o número do whatsApp!';
                                              }
                                              if (value.length < 14) {
                                                return 'Número incompleto!';
                                              }
                                              return null;
                                            },
                                          ),

                                          //const SizedBox(height: 20),

                                          //CPF
                                          
                                          TextFormField(
                                            keyboardType: TextInputType.number,
                                            //maxLength: 14,
                                            maxLengthEnforcement:
                                                MaxLengthEnforcement.enforced,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold),
                                            controller: _cpfController,
                                            decoration: inputDec('CPF'),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Por favor, digite o CPF do cliente!';
                                              }
                                              if (value.length < 14) {
                                                return 'CPF incompleto!';
                                              }
                                              return null;
                                            },
                                          ),
                                          
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child:
                                                // EMAIL
                                                TextFormField(
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold),
                                              controller: _emailController,
                                              decoration: inputDec('Email'),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Por favor, digite o email!';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child:
                                                //WHATSAPP
                                                TextFormField(
                                              //maxLength: 14,
                                              //maxLengthEnforcement: MaxLengthEnforcement.enforced,

                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold),
                                              controller: _wppController,
                                              decoration: inputDec('Whatsapp'),
                                              keyboardType: TextInputType.phone,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Por favor, digite o número do whatsApp!';
                                                }
                                                if (value.length < 14) {
                                                  return 'Número incompleto!';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child:
                                                //CPF
                                                TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              //maxLength: 14,
                                              maxLengthEnforcement:
                                                  MaxLengthEnforcement.enforced,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold),
                                              controller: _cpfController,
                                              decoration: inputDec('CPF'),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Por favor, digite o CPF do cliente!';
                                                }
                                                if (value.length < 14) {
                                                  return 'CPF incompleto!';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),

                                const SizedBox(height: 40),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientBtn(),
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _registerOrEditCliente,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        fixedSize: Size(size.width * 0.35,
                                            size.height * 0.01),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    child: Text('Confirmar',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.height * 0.022,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ])));
  }
}
