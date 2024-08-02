import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RegistraCliente extends StatefulWidget {
  final String? clienteId;

  RegistraCliente({super.key, this.clienteId});

  @override
  _RegistraClienteState createState() => _RegistraClienteState();
}

class _RegistraClienteState extends State<RegistraCliente> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _wppController = TextEditingController();
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
    DocumentSnapshot cliente = await FirebaseFirestore.instance
        .collection('clientes')
        .doc(widget.clienteId)
        .get();
    _nameController.text = cliente['name'];
    _emailController.text = cliente['email'];
    _wppController.text = cliente['whatsapp'];

    setState(() {
      _isLoading = false;
    });
  }

  void _registerOrEditCliente() async {
    
    if (_formKey.currentState!.validate()) {
      if (widget.clienteId == null) {
        await FirebaseFirestore.instance.collection('clientes').add({
          'name': _nameController.text,
          'email': _emailController.text,
          'whatsapp': _wppController.text,
          'data_registro': DateTime.now()
        });
      } else {
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'whatsapp': _wppController.text,
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const  BoxDecoration(
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 200, vertical: 100),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
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
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.clienteId == null
                                ? 'Registro de Cliente'
                                : 'Edição de Cliente',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 38,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 35),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome do Cliente',
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                              ),
                               errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 238, 255, 0)), // Cor da borda quando há erro
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              
                              errorStyle: TextStyle( // Estilo do texto de erro
                                color: Color.fromARGB(255, 238, 255, 0), // Cor do texto de erro
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite o nome do Cliente!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                              ),

                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 238, 255, 0)), // Cor da borda quando há erro
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),

                              errorStyle: TextStyle( // Estilo do texto de erro
                                color: Color.fromARGB(255, 238, 255, 0), // Cor do texto de erro
                              ),

                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                              ),


                               
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite o Email!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: _wppController,
                            decoration: const InputDecoration(
                              labelText: 'Número do WhatsApp',
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                              ),
                               errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 238, 255, 0)), // Cor da borda quando há erro
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                              
                              errorStyle: TextStyle( // Estilo do texto de erro
                                color: Color.fromARGB(255, 238, 255, 0), // Cor do texto de erro
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite o número do WhatsApp!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _registerOrEditCliente,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              minimumSize: Size(2000, 42),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                            child: Text(
                              widget.clienteId == null
                                  ? 'Registrar Cliente'
                                  : 'Editar Cliente',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
                      )
                    )
                  );
                }
              )
                
            ),
                    
                  
    );
  }
}
