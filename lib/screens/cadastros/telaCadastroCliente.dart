import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class RegistraCliente extends StatefulWidget {
  final String? clienteId;
  final String? email;

  RegistraCliente({super.key, this.clienteId, this.email});

  @override
  _RegistraClienteState createState() => _RegistraClienteState();
}

class _RegistraClienteState extends State<RegistraCliente> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _wppController = MaskedTextController(mask: '(00) 0000-0000');
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
        .where('email_user', isEqualTo: widget.email)
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
          'whatsapp': _wppController.text.replaceAll(RegExp(r'\D'), ''),
          'data_registro': DateTime.now(),
          'email_user': widget.email
        });
      } else {
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'whatsapp': _wppController.text.replaceAll(RegExp(r'\D'), ''),
          'email_user': widget.email
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
          backgroundColor: Color.fromRGBO(89, 19, 165, 1.0),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Wrap(children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(left: 150, right: 150),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               
                                // NOME DO CLIENTE
                                TextFormField(
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nome do Cliente',
                                labelStyle: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, digite o nome do Cliente!';
                                }
                                return null;
                              },
                            ),
                                

                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      child: 
                                      // EMAIL
                                        TextFormField(
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold),
                                      controller: _emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        labelStyle: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, digite o Email!';
                                        }
                                        return null;
                                      },
                                    ),
                                  
                                    ),

                                    const SizedBox(width: 20,),
                                    Expanded(child: 
                                      //WHATSAPP
                                      TextFormField(
                                        maxLength: 14,
                                        maxLengthEnforcement:
                                            MaxLengthEnforcement.enforced,
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold),
                                        controller: _wppController,
                                        decoration: const InputDecoration(
                                          labelText: 'Número do WhatsApp',
                                          labelStyle: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, digite o número do WhatsApp!';
                                          }
                                          if (value.length < 14) {
                                            return 'Número incompleto!';
                                          }
                                          return null;
                                        },
                                      ),

                                    ),

                                    const SizedBox(width: 20,),
                                    Expanded(child: 
                                      //CPF
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        maxLength: 14,
                                        maxLengthEnforcement:
                                            MaxLengthEnforcement.enforced,
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold),
                                        controller: _nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'CPF',
                                          labelStyle: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, digite o CPF do cliente!';
                                          }
                                          if (value.length < 14) {
                                            return 'CPF incompleto!';
                                          }
                                          return null;
                                        },
                                      ),

                                    ),
                                ],),

                                
                               

                                const SizedBox(height: 50),
                                ElevatedButton(
                                  onPressed: _registerOrEditCliente,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(89, 19, 165, 1.0),
                                    minimumSize: Size(2000, 42),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  child: Text(
                                    widget.clienteId == null
                                        ? 'Cadastrar'
                                        : 'Editar',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
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
