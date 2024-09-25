// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductRegisterScreen extends StatefulWidget {
  final String? productId;
  final String? email;

  ProductRegisterScreen({super.key, this.productId, this.email});

  @override
  _ProductRegisterScreenState createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descontoController = TextEditingController();
  int _recurrencePeriod = 30;
  String _paymentOption = 'Cartão de crédito/débito';
  bool _isLoading = false;

  final List<RecurrencePeriod> recurrencePeriods = [
    RecurrencePeriod(30, 'Mensal'),
    RecurrencePeriod(60, 'Bimestral'),
    RecurrencePeriod(90, 'Trimestral'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

//.where('email_user', isEqualTo: widget.email)
  void _loadProduct() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: widget.email)
        .get();

    // Verificar se há documentos retornados pela consulta
    if (querySnapshot.docs.isNotEmpty) {
      // Percorre todos os documentos retornados pela consulta
      for (var doc in querySnapshot.docs) {
        if (doc.id == widget.productId) {
          var productData = doc.data() as Map<String, dynamic>;

          _nameController.text = productData['name'];
          _priceController.text = productData['price'].toString();
          _descontoController.text = productData['desconto'].toString();
          _recurrencePeriod = productData['recurrencePeriod'];
          _paymentOption = productData['paymentOption'];
          break;
        }
      }
    } else {
      // Tratar o caso onde nenhum documento foi encontrado
      print('Nenhum produto encontrado para este usuário.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _registerOrEditProduct() async {
    if (_formKey.currentState!.validate()) {
      if (widget.productId == null) {
        // Register new product
        await FirebaseFirestore.instance.collection('products').add({
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
          'desconto': int.parse(_descontoController.text),
          'recurrencePeriod': _recurrencePeriod,
          'paymentOption': _paymentOption,
          'email_user': widget.email
        });
      } else {
        // Update existing product
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update({
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
          'desconto': int.parse(_descontoController.text),
          'recurrencePeriod': _recurrencePeriod,
          'paymentOption': _paymentOption,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Produto ${widget.productId == null ? 'registrado' : 'atualizado'} com sucesso!')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.productId == null ? 'Cadastrar Produtos' : 'Editar Produtos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            )),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(89, 19, 165, 1.0),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 200, vertical: 100),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // NOME DO PRODUTO
                                  TextFormField(
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nome do produto',
                                      labelStyle: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor digite o nome do produto';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // PREÇO
                                  TextFormField(
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                    controller: _priceController,
                                    decoration: InputDecoration(
                                      labelText: 'Preço',
                                      labelStyle: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor digite o preço';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // VALOR DE DESCONTO
                                  TextFormField(
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                    controller: _descontoController,
                                    decoration: InputDecoration(
                                      labelText: 'Valor de Desconto (%)',
                                      labelStyle: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor digite o valor de desconto!';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // PERÍODO DE RECORRÊNCIA
                                  DropdownButtonFormField<int>(
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                    value: _recurrencePeriod,
                                    dropdownColor: Colors.white,
                                    decoration: InputDecoration(
                                      labelText: 'Período de recorrência',
                                      labelStyle: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    items: recurrencePeriods
                                        .map((RecurrencePeriod periodo) {
                                      return DropdownMenuItem<int>(
                                        value: periodo.value,
                                        child: Text(periodo.text),
                                      );
                                    }).toList(),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        _recurrencePeriod = newValue!;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // OPÇÃO DE PAGAMENTOS
                                  DropdownButtonFormField<String>(
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                    value: _paymentOption,
                                    dropdownColor: Colors.white,
                                    decoration: InputDecoration(
                                      labelText: 'Opção de Pagamento',
                                      labelStyle: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    items: [
                                      'Cartão de crédito/débito',
                                      'Pix',
                                      'Ambos'
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _paymentOption = newValue!;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _registerOrEditProduct,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(89, 19, 165, 1.0),
                                        minimumSize: Size(2000, 42),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    child: Text(
                                      widget.productId == null
                                          ? 'Cadastrar'
                                          : 'Editar',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Spacer(),
                                ],
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

class RecurrencePeriod {
  final int value;
  final String text;

  RecurrencePeriod(this.value, this.text);
}