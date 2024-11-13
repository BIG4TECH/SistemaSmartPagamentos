import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_pagamento/classes/api_service.dart';
import 'package:smart_pagamento/screens/widgets/cores.dart';
import 'package:smart_pagamento/screens/widgets/editarNumero.dart';
import 'package:smart_pagamento/screens/widgets/showdialog.dart';
import 'package:smart_pagamento/screens/widgets/textfield.dart';

class ProductRegisterScreen extends StatefulWidget {
  final String? productId;
  final String? idUser;

  ProductRegisterScreen({super.key, this.productId, required this.idUser});

  @override
  _ProductRegisterScreenState createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  int _recurrencePeriod = 1;
  bool _isLoading = false;
  late int _planId;
  bool _isDollar = false;

  bool _isCreditCardSelected = false;
  bool _isPixSelected = false;
  bool _isBoletoSelected = false;

  final List<RecurrencePeriod> recurrencePeriods = [
    RecurrencePeriod(1, 'Mensal'),
    RecurrencePeriod(2, 'Bimestral'),
    RecurrencePeriod(3, 'Trimestral'),
    RecurrencePeriod(6, 'Semestral'),
    RecurrencePeriod(12, 'Anual'),
  ];

  @override
  void initState() {
    super.initState();

    if (widget.productId != null) {
      _loadProduct();
    }
  }

  String _getPaymentOption() {
    if (_isCreditCardSelected && _isPixSelected && _isBoletoSelected) {
      return 'Ambos';
    } else if (_isCreditCardSelected) {
      return 'Cartão';
    } else if (_isPixSelected) {
      return 'Pix';
    } else if (_isBoletoSelected) {
      return 'Boleto';
    } else if (_isCreditCardSelected && _isPixSelected) {
      return 'Cartão/Pix';
    } else if (_isCreditCardSelected && _isBoletoSelected) {
      return 'Cartão/Boleto';
    } else if (_isBoletoSelected && _isPixSelected) {
      return 'Pix/Boleto';
    }
    return '';
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nome existente!'),
          content: Text('Por favor, escolha outro nome para o produto.'),
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
  }

  Future<bool> _nameExist(String nome, String? idUser) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: idUser)
        .where('name', isEqualTo: nome)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return false;
    }
    return querySnapshot.docs.first['name'] == nome ? true : false;
  }

  void _loadProduct() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('email_user', isEqualTo: widget.idUser)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        if (doc.id == widget.productId) {
          var productData = doc.data() as Map<String, dynamic>;

          _nameController.text = productData['name'];
          _priceController.text = productData['price'].toString();
          _recurrencePeriod = productData['recurrencePeriod'];
          _isDollar = productData['is_dollar'];

          String paymentOption = productData['paymentOption'];
          _isCreditCardSelected =
              paymentOption == 'Cartão' || paymentOption == 'Ambos';
          _isPixSelected = paymentOption == 'Pix' || paymentOption == 'Ambos';
          _isBoletoSelected =
              paymentOption == 'Boleto' || paymentOption == 'Ambos';
          _planId = productData['plan_id'];
          break;
        }
      }
    } else {
      print('Nenhum produto encontrado para este usuário.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _registerOrEditProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      if (widget.idUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email do usuário não encontrado.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (!_isCreditCardSelected && !_isPixSelected && !_isBoletoSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Selecione pelo menos uma forma de pagamento.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      bool nameExists = await _nameExist(_nameController.text, widget.idUser);
      ApiService apiService = ApiService();

      if (widget.productId == null && nameExists) {
        _showDialog(context);
        setState(() {
          _isLoading = false;
        });
        return;
      } else {
        if (widget.productId == null) {
          var responsePlanoPosted = await apiService.criarPlano(
              _nameController.text, 2, _recurrencePeriod);

          if (responsePlanoPosted['status'] == 200) {
            await FirebaseFirestore.instance.collection('products').add({
              'name': _nameController.text,
              'plan_id': responsePlanoPosted['body']['data'],
              'price': double.parse(formatarNumero(double.parse(_priceController.text))),
              'is_dollar': _isDollar,
              'recurrencePeriod': _recurrencePeriod,
              'paymentOption': _getPaymentOption(),
              'email_user': widget.idUser
            });
          } else {
            showDialogApi(context);
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } else {
          var responseDelete = await apiService.deletarPlano(_planId);

          if (responseDelete['status'] == 200) {
            var responsePlanoPosted = await apiService.criarPlano(
                _nameController.text, 2, _recurrencePeriod);

            if (responsePlanoPosted['status'] == 200) {
              var novoPlanId = responsePlanoPosted['body']['data'];
              var antigoPlanId = await FirebaseFirestore.instance
                  .collection('products')
                  .doc(widget.productId)
                  .get()
                  .then((doc) => doc['plan_id']);

              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(widget.productId)
                  .update({
                'name': _nameController.text,
                'plan_id': novoPlanId,
                'price': double.parse(formatarNumero(double.parse(_priceController.text))),
                'is_dollar': _isDollar,
                'recurrencePeriod': _recurrencePeriod,
                'paymentOption': _getPaymentOption(),
              });

              var vendas =
                  await FirebaseFirestore.instance.collection('vendas').get();

              for (var venda in vendas.docs) {
                if (venda['plan']['id'] == antigoPlanId) {
                  await FirebaseFirestore.instance
                      .collection('vendas')
                      .doc(venda.id)
                      .update({
                    'plan': {'id': novoPlanId}
                  });
                }
              }
            } else {
              showDialogApi(context);
              setState(() {
                _isLoading = false;
              });
              return;
            }
          } else {
            showDialogApi(context);
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Produto ${widget.productId == null ? 'registrado' : 'atualizado'} com sucesso!')));
        _nameController.clear();
        _priceController.clear();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.productId == null
                  ? 'Cadastro de Produtos'
                  : 'Edição de Produtos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 38,
              )),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: corPadrao(),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: size.width <= 720
                ? EdgeInsets.symmetric(
                    horizontal: size.width * 0.07, vertical: size.width * 0.07)
                : EdgeInsets.symmetric(
                    horizontal: size.width * 0.05, vertical: size.width * 0.05),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // NOME DO PRODUTO
                    TextFormField(
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                      controller: _nameController,
                      decoration: inputDec('Nome do Produto'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite o nome do produto';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // PREÇO
                    size.width <= 720
                        ? Column(
                            children: [
                              TextFormField(
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                                controller: _priceController,
                                decoration: inputDec('Valor'),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, digite o valor';
                                  }
                                  return null;
                                },
                              ),
                              Card(
                                child: CheckboxListTile(
                                  title: Text('Valor em Dólar'),
                                  value: _isDollar,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isDollar = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                  controller: _priceController,
                                  decoration: inputDec('Valor'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite o valor';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: CheckboxListTile(
                                    title: Text('Valor em Dólar'),
                                    value: _isDollar,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isDollar = value!;
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
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
                      decoration: inputDec('Período de Recorrência'),
                      items: recurrencePeriods.map((RecurrencePeriod periodo) {
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

                    // CHECKBOXES PARA OPÇÕES DE PAGAMENTO
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Forma de Pagamento',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        size.width <= 720
                            ? Column(
                                children: [
                                  Card(
                                    child: CheckboxListTile(
                                      title: Text('Cartão'),
                                      value: _isCreditCardSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isCreditCardSelected = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Card(
                                    child: CheckboxListTile(
                                      title: Text('Pix'),
                                      value: _isPixSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isPixSelected = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Card(
                                    child: CheckboxListTile(
                                      title: Text('Boleto'),
                                      value: _isBoletoSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isBoletoSelected = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                      child: Card(
                                    child: CheckboxListTile(
                                      title: Text('Cartão'),
                                      value: _isCreditCardSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isCreditCardSelected = value!;
                                        });
                                      },
                                    ),
                                  )),
                                  Expanded(
                                      child: Card(
                                    child: CheckboxListTile(
                                      title: Text('Pix'),
                                      value: _isPixSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isPixSelected = value!;
                                        });
                                      },
                                    ),
                                  )),
                                  Expanded(
                                    child: Card(
                                      child: CheckboxListTile(
                                        title: Text('Boleto'),
                                        value: _isBoletoSelected,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _isBoletoSelected = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                      ],
                    ),

                    SizedBox(height: 20),

                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientBtn(),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              onPressed: _registerOrEditProduct,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  fixedSize: Size(
                                      size.width * 0.35, size.height * 0.01),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              child: Text(
                                  widget.productId != null
                                      ? 'Editar'
                                      : 'Cadastrar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.height * 0.022,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class RecurrencePeriod {
  final int value;
  final String text;

  RecurrencePeriod(this.value, this.text);
}
