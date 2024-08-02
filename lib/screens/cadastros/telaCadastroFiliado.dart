import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RegistraFiliado extends StatefulWidget {
  final String? filiadoId;

  RegistraFiliado({Key? key, this.filiadoId}) : super(key: key);

  @override
  _RegistraFiliadoState createState() => _RegistraFiliadoState();
}

class _RegistraFiliadoState extends State<RegistraFiliado> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _wppController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if(widget.filiadoId != null){
      _loadCliente();
    }
  }

  void _loadCliente() async {
    setState(() {
      _isLoading = true;
    });
    DocumentSnapshot cliente = await FirebaseFirestore.instance
        .collection('filiados')
        .doc(widget.filiadoId)
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
      if (widget.filiadoId == null) {
        // Registrar cliente
        await FirebaseFirestore.instance.collection('filiados').add({
          'name': _nameController.text,
          'email': _emailController.text,
          'whatsapp': _wppController.text,
        });
      } else {
        // Atualizar cliente
        await FirebaseFirestore.instance
            .collection('filiados')
            .doc(widget.filiadoId)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'whatsapp': _wppController.text,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Filiado ${widget.filiadoId == null ? 'registrado' : 'atualizado'} com sucesso!'),
      ));
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
        
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                                widget.filiadoId == null ? 'Registro de Filiado' : 'Edição de Filiado',
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
                                  labelText: 'Nome do Filiado',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 238, 255, 0)),
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  errorStyle: TextStyle(color: Color.fromARGB(255, 238, 255, 0)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, digite o nome do Filiado!';
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
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 238, 255, 0)),
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  errorStyle: TextStyle(color: Color.fromARGB(255, 238, 255, 0)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
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
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 238, 255, 0)),
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  errorStyle: TextStyle(color: Color.fromARGB(255, 238, 255, 0)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
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
                                  minimumSize: const Size(2000, 42),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  widget.filiadoId == null ? 'Registrar Filiado' : 'Editar Filiado',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
